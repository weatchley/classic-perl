###############################################################################################################
sub updateBaseline {
#
# Creates new baseline items in the baseline items table.
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#			id               - id of config item promoted to baseline item
#		   majorVersion         - major revision number of configuration item
#			minorVersion         - minor revision number of configuration item
#        date             - date of configuration item inclusion in the baseline
#
###############################################################################################################
    my %args = (
        schema => "$SCHEMA",
        scr => "",
        baselineDate => "",
        @_,
    );	
    my ($dbh, $schema, $scr, $baselineDate) = @_;
	
   my $sqlquery = "UPDATE $args{schema}.baseline_item SET superceded_date = TO_DATE('$args{baselineDate}', 'MM/DD/YYYY HH:MI:SS') "
                  . "WHERE item_id in (SELECT item_id FROM $args{schema}.item_version WHERE approval_date IS NOT NULL AND scr = $args{scr} AND status_id = 1) "
                  . "AND superceded_date IS NULL";
   #print "\n$sqlquery";
   $dbh->do($sqlquery);
   
   $sqlquery = "INSERT INTO $args{schema}.baseline_item (item_id, major_version, minor_version, baseline_date) "
	            . "SELECT item_id, major_version, minor_version, TO_DATE('$args{baselineDate}','MM/DD/YYYY HH:MI:SS') FROM $args{schema}.item_version "
					. "WHERE approval_date IS NOT NULL AND scr = $args{scr} AND status_id = 1 "
					. "AND (item_id, major_version, minor_version) NOT IN (SELECT item_id, major_version, minor_version FROM "
					. "$args{schema}.baseline_item) ";
   #print "\n~~ $sqlquery ";
   $dbh->do($sqlquery);
}


#############################################################################################################
sub checkInConfigItem {  
#	
# Check in a configuration item 
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle	
#        userId           - id of the user checking the configuration item out  
#        configId         - id of the configuration item to be checked out 
#			description      - desciption of changes to the configuration item
#
#############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my $sqlquery = "SELECT major_version, minor_version, developer_id, scr FROM $args{schema}.item_version WHERE "
	            	. "item_id = $args{configId} AND (major_version, minor_version) IN "
						. "(SELECT MAX(major_version), MAX(minor_version) FROM $args{schema}.item_version WHERE "
						. "item_id = $args{configId} GROUP BY item_id)";
	#print STDERR "\n\n$sqlquery\n";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	my ($majorVersion, $minorVersion, $responsibleDevId, $scrid) = $sth->fetchrow_array;
	$sqlquery = "UPDATE $args{schema}.item_version SET status_id = 3, locker_id = NULL WHERE item_id = $args{configId} and minor_version = $minorVersion ";
	$args{dbh}->do($sqlquery);
	$args{description} = $args{dbh}->quote($args{description});
	$minorVersion += 1;
	$sqlquery = "INSERT INTO $args{schema}.item_version(item_id, "
	            . "major_version, minor_version, version_date, status_id, developer_id, "
	            . "change_description, scr) VALUES ($args{configId}, "
	            . "$majorVersion, $minorVersion, SYSDATE, 1, $args{userId}, $args{description}, $scrid)";
	#print STDERR "$sqlquery\n";
	$args{dbh}->do($sqlquery);
}


##############################################################################################################
sub checkOutConfigItem {  
#	
# Check out a configuration item  
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle	
#        userId           - id of the user checking the file out
#			scrId            - id of the scr for which the item is to be modified  
#        configId         - id of the configuration item to be checked out  
#
##############################################################################################################

	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my $sqlquery = "UPDATE $args{schema}.item_version SET status_id = 2, locker_id = $args{userId}, "
						. "SCR = $args{scrId} "
						. "WHERE item_id = $args{configId} AND (major_version, minor_version) IN "
						. "(SELECT MAX(major_version), MAX(minor_version) FROM $args{schema}.item_version WHERE "
						. "item_id = $args{configId} GROUP BY item_id)";
	#print "\n\n$sqlquery\n";
	$args{dbh}->do($sqlquery);
	
}	


############################################################################################################
sub getSCR {
#
#  	Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#		   projectId        - id of project
#        option           - this specifies the subset of SCR's to retrieve
#        	Option Types
#					ACCEPTED   - retrieves all the accepted SCR's associated with a project
#
############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	tie my %scr, "Tie::IxHash";
	my $sqlquery;
	if (uc($args{option}) eq "ACCEPTED") {
		$sqlquery = "SELECT id, datesubmitted, description, rationale, submittedby, status, priority, product, "
	               . "datecompleted, estimatedcost, actualcost, developer, datedue, dateapproved, actionstaken, "
	               . "rejectionrationale, lastupdated, updatedby FROM $args{schema}.scrrequest "
	               . "WHERE status = 3 AND product = $args{projectId} order by id";
	}
	#print "\n$sqlquery\n";
	$args{dbh}->{LongTruncOk} = 1;
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	while (my ($id, $dateSubmitted, $description, $rationale, $submittedBy, $status, $priority, $product,
	       	  $dateCompleted, $estimatedCost, $actualCost, $developer, $dateDue, $dateApproved, $actionsTaken,
	           $rejectionRationale, $lastupDated, $updatedBy) = $sth->fetchrow_array) {
		$scr{$id} = {
							'datesubmitted' 		=> $dateSubmitted,
							'description'   		=> $description,
							'rationale'     		=> $rationale,
							'submittedby'   		=> $submittedBy,
							'status'        		=> $status,
							'priority'      		=> $priority,
							'product'       		=> $product,
							'datecompleted' 		=> $dateCompleted,
							'estimatedcost' 		=> $estimatedCost,
							'actualcost'    		=> $actualCost,
							'developer'     		=> $developer,
							'datedue'       		=> $dateDue,
							'dateapproved'  		=> $dateApproved,
							'actionstaken'       => $actionsTaken,
							'rejectionrationale' => $rejectionRationale,
							'lastupdated'			=> $lastupDated,
							'updatedby'				=> $updatedBy
				 		};
	}
	$args{dbh}->{LongTruncOk} = 0;
	return (%scr);
}

###############################################################################################################
sub getItemSource {  
#
# Get all the defined configuration item sources
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#
###############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	my $sqlquery = "SELECT id, source FROM $args{schema}.item_source";
	my %items;
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	while (my ($id, $source) = $sth->fetchrow_array) {
		$items{$id} = $source;
	} 
	return (%items);
}

################################################################################################################
sub createBaseline {
#	
# Creates a new baseline for a project in the SCM system.	
#	
#		Named Parameters:	
#     	schema      	  - database schema	
#     	dbh         	  - database handle 
#        itemId           - configuration item id 
#        major_version        - major revision number of the configuration item	
#        minor_version        - minor revision number of the configuration item	
#	
################################################################################################################
    my %args = (
        schema => "$SCHEMA",
        @_,
    );

    my $sqlquery = "INSERT INTO $args{schema}.baseline_item (item_id, major_version, minor_version, baseline_date) "
				   . "VALUES ( $args{itemId}, $args{major_version},  $args{minor_version}, TO_DATE('$args{baselineDate}', 'MM/DD/YYYY HH:MI:SS'))";
    $args{dbh}->prepare($sqlquery);
    $args{dbh}->do($sqlquery);
    return (1);
}


#############################################################################################################
sub getConfigItems {
#
#	Retrieve a subset of configuration items based on the option specified.
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#		   projectId        - id of project
#		   userId           - id of user
#        option           - this specifies what subset of configuration to retrieve
#        	Option Types
#					LATEST 		- retrieves the latest versions of all the configuration items associated with
#                            a project
#					ALL   		- retrieves all the configuration items associated with a project
#					APPROVED 	- retrieves all approved configuration items associated with a project
#					CHECKEDOUT  - retrieves all configuration items that are checked out by a user
#              BASELINE    - retrieves all configuration items associated with completed SCR's (scr_id = 5)
#                            that are not in the current baseline
#              BASELINE_UPDATE - retrieves all configuration items associated with completed SCR's (scr_id = 5)
#                                that are not in the current baseline and sorted by SCR
#					DATABASE		- retrieves all the configuration items that are databases
#					NEW   		- retrieves all the configuration items not associated with an SCR
#############################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	tie my %config, "Tie::IxHash";	
	my $sqlquery = "SELECT cfg.id, name, version_date, developer_id, change_description, "
	  	      	   . "rev.status_id, TO_CHAR(approval_date, 'MM/DD/YYYY'), locker_id, "
	  	      	   . "scr, major_version, minor_version, source_id, type_id FROM $args{schema}.configuration_item cfg, $args{schema}.item_version rev";
	if (uc($args{option}) eq "LATEST") {
		$sqlquery .= " WHERE project_id = $args{projectId} AND id = item_id AND status_id = 1 AND type_id not in (4,5) AND "
		             . "(item_id, major_version, minor_version) IN (SELECT item_id, MAX(major_version), MAX(minor_version) "
		             . "FROM $args{schema}.item_version GROUP BY item_id) order by name";   
	}
	elsif (uc($args{option}) eq "ALL") {
		$sqlquery .= "  WHERE project_id = $args{projectId} AND id = item_id order by name";
	}
	elsif (uc($args{option}) eq "APPROVED") {
		$sqlquery .= " WHERE approval_date IS NOT NULL AND project_id = $args{projectId} AND id = item_id order by name"
	}
	elsif (uc($args{option}) eq "CHECKEDOUT") {
		$sqlquery .= " WHERE project_id = $args{projectId} and locker_id = $args{userId} AND id = item_id AND status_id = 2 order by name";
	}
	elsif (uc($args{option}) eq "PRODUCT_UPDATE") {
		$sqlquery .= "SELECT cfg.id, name, revision_date AS version_date, responsible_developer_id AS developer_id, change_description, rev.STATUS AS status_id, "
						 . "TO_CHAR(approval_date, 'MM/DD/YYYY'), locker_id, scr_id, bsi.major_version, bsi.minor_version, "
                   . "source_id, type_id "
		             . ", baseline_item bsi WHERE superceded_date IS NULL AND project_id = 2 AND bsi.item_id = cfg.id AND bsi.item_id = rev.item_id "
		             . "AND rev.item_id = cfg.id AND "
                   . "bsi.major_version = rev.major_version AND bsi.minor_version = rev.minor_version AND "
                   . "rev.status = 1";
	}
	elsif (uc($args{option}) eq "BASELINE_UPDATE") {
		$sqlquery = "SELECT cfg.id, name, version_date, developer_id, scr.description, "
		  	      	 . "rev.status_id, TO_CHAR(approval_date, 'MM/DD/YYYY'), locker_id, "
	  	      	    . "scr, major_version, minor_version, source_id, type_id FROM $args{schema}.configuration_item cfg, $args{schema}.item_version rev, "
						 . " $args{schema}.scrrequest scr WHERE approval_date IS NOT NULL AND project_id = $args{projectId} "
						 . "AND cfg.id = item_id AND scr = scr.id(+) AND (scr.status = 5 OR scr = 0) AND rev.status_id = 1 "
						 . "AND (cfg.id, major_version, minor_version) NOT IN (SELECT item_id, major_version, minor_version FROM "
						 . "$args{schema}.baseline_item) order by scr, name ";
	}
	elsif (uc($args{option}) eq "NEW") {
		$sqlquery .= " WHERE project_id = $args{projectId} AND rev.status_id = 1 "
						 . "AND (rev.scr IS NULL OR rev.scr = 0 ) order by name";
	}	
	elsif (uc($args{option}) eq "DATABASE") {
		$sqlquery .= " WHERE project_id = $args{projectId} AND id = item_id AND status_id = 1 AND type_id in (4,5) AND "
				     	 . "(item_id, major_version, minor_version) IN (SELECT item_id, MAX(major_version), MAX(minor_version) "
		             . "FROM $args{schema}.item_version GROUP BY item_id) order by name";
	}
	#print "\n ~~$sqlquery\n";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	my $i = 0;
	while (my ($configId, $name, $revDate, $developerId, $desc, $status, $approvalDate, 
	           $lockerId, $id, $majorVersion, $minorVersion, $sourceId, $typeId) = $sth->fetchrow_array) {
		$config{$configId} = {			
									'name' 		   => $name,
									'revDate'      => $revDate,
									'developer'    => $developerId,
									'majorVersion' => $majorVersion,
									'minorVersion' => $minorVersion,
									'description'  => $desc,
									'status'       => $status,
									'approvalDate' => $approvalDate,
									'locker'       => $lockerId,
									'scr'          => $id,
									'sourceId'     => $sourceId,
									'typeId'       => $typeId,
							  };			  
	}
		
	return (%config);
}

###############################################################################################################
sub createConfigItem { 
#
# Create a new configuration item 
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#			name             - name of configuration item
#			sourceId         - source of the configuration item
#        typeId           - type of the configuration item
#        projectId        - id of the project the configuration is associated with
#        developerId      - id of the developer of the configuration item
#        changeDescripton - configuration item change purpose
#        scrId            - software change request associated with the configuration item
#
###############################################################################################################

	my %args = (
		schema => "$SCHEMA",
		@_,
	);
	$args{name} = $args{dbh}->quote($args{name});
	$args{changeDescription} = $args{dbh}->quote($args{changeDescription});
   my $date = &getSysdate(dbh => $args{dbh}, schema => $args{schema});
	my $sqlquery = "INSERT INTO $args{schema}.configuration_item "
	               . "(id, name, source_id, type_id, project_id) VALUES "
	               . "($args{schema}.CONFIG_ITEM_SEQ.NEXTVAL, $args{name}, $args{sourceId}, $args{typeId}, "
	               . "$args{projectId})";
	#print "\n~~$sqlquery\n";
	$args{dbh}->do($sqlquery);
	$sqlquery = "INSERT INTO $args{schema}.item_version (item_id, major_version, minor_version, version_date, status_id, "
	            . "developer_id, change_description, scr) VALUES ($args{schema}.CONFIG_ITEM_SEQ.CURRVAL, 1, 1, "
	            . "TO_DATE('$date', 'MM/DD/YYYY HH:MI:SS'), 1, $args{developerId}, 'Initial revision', "
	            . "$args{scrId})";
	#print "\n~~~~$sqlquery\n";
	$args{dbh}->do($sqlquery);
	#$sqlquery = "SELECT CONFIG_ITEM_SEQ.CURRVAL FROM $args{schema}.configuration_item";
	#my $sth = $args{dbh}->prepare($sqlquery);
	#$sth->execute;
	#$args{dbh}->rollback;
	#return($sth->fetchrow_array);
	return (1);
}

################################################################################################################
sub getBaselineItems {
#
# Get baseline items to create a new or new version of a product for a project							
#
#     	schema      	  - database schema	
#     	dbh         	  - database handle 
#        projectId        - id of the project the configuration items are associated with
#        option
#                         NEW_PRODUCT_ITEMS
#                           - Retrieve all baseline items associated with a scr_id = 0
#								  OLD_PRODUCT_ITEMS
#                           - Retrieve all baseline items associated with a scr_id != 0
#
################################################################################################################
	my %args = (
		schema => "$SCHEMA",
		@_,
   );	
   my %baseline;
	my $sqlquery = "SELECT cfg.id, name, rev.major_version, rev.minor_version, version_date, "
                  . "developer_id, scr, change_description, rev.STATUS_id, approval_date, locker_id, "
 						. "source_id, type_id, TO_CHAR(baseline_date, 'MM/DD/YYYY') FROM "
	               . "$args{schema}.baseline_item bse, $args{schema}.configuration_item cfg, $args{schema}.item_version rev "
						. "WHERE bse.item_id = cfg.id AND cfg.id = rev.item_id AND rev.major_version = bse.major_version "
		  	      	. "AND rev.minor_version = bse.minor_version AND project_id = $args{projectId} AND superceded_date IS NULL";
	if (uc($args{option}) eq "NEW_PRODUCT_ITEMS") {
		$sqlquery .= " AND rev.scr = 0";
	}		
	elsif (uc($args{option}) eq "OLD_PRODUCT_ITEMS") {
		$sqlquery .= " AND rev.scr != 0";
	}
	#print "$sqlquery\n";
   my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
	$sqlquery = "SELECT item_id FROM $args{schema}.baseline_product_item WHERE (?, ?, ?) IN "
	            . "(SELECT item_id, item_major_version, item_minor_version FROM $args{schema}.baseline_product_item)";
	my $sth1 = $args{dbh}->prepare($sqlquery);
	while (my ($configId, $name, $majorVersion, $minorVersion, $revDate, $creationDate, 
		        $developerId, $scr, $desc, $status, $approvalDate, $lockerId, $sourceId, $typeId, $baselineDate) = $sth->fetchrow_array) {
		$baseline{$configId} = {
											'name' 		    => $name,
											'majorVersion'  => $majorVersion,
											'minorVersion'  => $minorVersion,
											'revDate'       => $revDate,
											'creationDate'  => $creationDate,
											'developer'     => $developerId,
											'scr'           => $scr,
											'description'   => $desc,
											'status'        => $status,
											'approvalDate'  => $approvalDate,
											'locker'        => $lockerId,
											'sourceId'      => $sourceId,
											'typeId'        => $typeId,
											'baselineDate'  => $baselineDate,
											'isnew'         => 'false'
								 		};
		$sth1->execute($configId, $majorVersion, $minorVersion);
		unless (defined($sth1->fetchrow_array)) {
			$baseline{$configId}{'isnew'} = 'true'; 
		}
	}
	return (%baseline);	
}

################################################################################################################
sub createProjectList{
################################################################################################################
	my (%projectlist) = @_;
	my $outstring = "";
	$outstring .= "<font size=-1><b>Project:&nbsp;&nbsp;</b></font><select name=projectID size=1>\n";
   $outstring .= "<option value=0 selected>All\n";
	foreach my $column (keys (%projectlist)) {
		$outstring .= "<option value=$column>$projectlist{$column}{'acronym'}\n";
	}
	$outstring .= "</select>\n";
}


############################################################################################################
sub createProduct {	
#
# Creates a new product associated with a specific project.
#
#		Named Parameters:
#     	schema      	- database schema
#     	dbh         	- database handle
#     	acronym        - acronym of the project the product is being created for
#        name           - name of the product
#        projectId      - id of the project the product is being created for
#        description    - product purpose
#        approveDate    - date the project was approved
#        items          - hash of configuration items that constitute the product passed by reference
#        	Keys:
#					id	      - id of configuration item
#					majorVersion - major version number of configuration item
#              minorVersion - minor version number of configuration item
#
############################################################################################################
	my %args = (																												
			  schema => "$SCHEMA",
	        @_,
   );
	$args{name} = $args{dbh}->quote($args{name});
	$args{description} = $args{dbh}->quote($args{description});
	
	my $sqlquery = "SELECT MAX(id) FROM $args{schema}.product";
	my $sth = $args{dbh}->prepare($sqlquery);
	$sth->execute;
   my $productId = $sth->fetchrow_array;
   
	$sqlquery = "INSERT INTO $args{schema}.product (id, name, major_version, minor_version, project_id, approve_date, "
	               . "release_date) VALUES (" . uc($args{acronym}) . "_PRODUCT_SEQ.NEXTVAL, $args{name}, "
	               . "1, 1, $args{projectId}, $args{approveDate}, SYSDATE)";
	$args{dbh}->do($sqlquery);
  
   $sqlquery = "INSERT INTO $args{schema}.baseline_product_item (product_id, product_major_version, product_minor_version, item_id, "
   	         . "item_major_version, item_minor_version) VALUES ($productId, 1, 1, ?, ?, ?)"; 
   $sth = $args{dbh}->prepare($sqlquery);
   foreach my $key (keys %{$args{items}}) {
   	$sth->execute($key, ${$args{items}}{$key}{majorVersion}, ${$args{items}}{$key}{minorVersion});
   }
}



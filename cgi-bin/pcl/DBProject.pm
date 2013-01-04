#
# $Source: /data/dev/rcs/pcl/perl/RCS/DBProject.pm,v $
#
# $Revision: 1.7 $
#
# $Date: 2003/02/03 21:56:51 $
#
# $Author: atchleyb $
#
# $Locker:  $
#
# $Log: DBProject.pm,v $
# Revision 1.7  2003/02/03 21:56:51  atchleyb
# removed refs to SCM
#
# Revision 1.6  2002/11/27 01:33:40  starkeyj
# modified create and update project functions to include the sccbid field
#
# Revision 1.5  2002/11/13 00:12:04  starkeyj
# modified function 'getProjectSCCB' to return 0 instead of undefined when the project has no SCCB
#
# Revision 1.4  2002/11/13 00:00:21  starkeyj
# added function 'getProjectSCCB' to return the sccbid of a project
#
# Revision 1.3  2002/11/07 16:09:00  starkeyj
# removed STDERR statements and comments
#
# Revision 1.2  2002/11/01 00:26:36  johnsonc
# Included functions to write to the activity log.
#
# Revision 1.1  2002/10/31 18:53:00  johnsonc
# Initial revision
#
#
#

package DBProject;
use strict;
use DBI;
use DBD::Oracle qw(:ora_types);
use DBShared qw(:Functions);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION $AUTOLOAD);

use Exporter;
$VERSION = 1.00;

@ISA = qw(Exporter);

@EXPORT = qw ();
@EXPORT_OK = qw(
    &createProject 		&updateProject 		&getProjectSCCB		&getSCCBName
    &getSCCBNames
);
%EXPORT_TAGS =( Functions => [qw(
   &createProject 		&updateProject 		&getProjectSCCB		&getSCCBName
   &getSCCBNames
)]);


###############################################################################################################
sub createProject { 	
#
# Creates a new project in the PCL system
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#     	acronym          - acronym of the project 
#        name             - name of the project
#        description      - project purpose
#        projectManagerId - id of project manager for the new project
#        userId 			  - id of project creator
#
###############################################################################################################
	my %args = (
		@_,
   );
	my ($sth, $sqlquery);
	my $sccbid = $args{sccbid} ? $args{sccbid} : "NULL";
	
	my $name = $args{name};
	$args{name} = $args{dbh}->quote($args{name});
	$args{description} = $args{dbh}->quote($args{description});
	$sqlquery = "INSERT INTO $args{schema}.project (id, name, acronym, description, creation_date, "
	            . "project_manager_id, requirements_manager_id, configuration_manager_id, created_by, sccbid) "
				   . "VALUES ($args{schema}.PROJECT_SEQ.NEXTVAL, $args{name}, " 
				   . $args{dbh}->quote(uc($args{acronym})) . ", $args{description}, SYSDATE, "
				   . "$args{projectManagerId}, $args{projectManagerId}, $args{projectManagerId}, $args{userId}, $sccbid)";

	$args{dbh}->do($sqlquery);
	&log_activity($args{dbh},$args{schema},$args{userId},"Project $name created");
	return (1);
	
}

###############################################################################################################
sub updateProject {	
#
# Set the attributes of an existing project
#
#		Named Parameters:
#     	schema      	  - database schema
#     	dbh         	  - database handle
#        projectId        - id of project
#        name             - name of the project
#        description      - project purpose
#        projectManagerId - id of project manager for the new project
#
#     Returns:
#
###############################################################################################################

	my %args = (
		@_,
	);
	my $name = $args{name};
 	my $sccbid = $args{sccbid};
	$args{description} = $args{dbh}->quote($args{description});
#	$args{acronym} = $args{dbh}->quote($args{acronym});
	my $sqlquery = "UPDATE $args{schema}.project SET ";
	if (defined($args{description}) && $args{description} ne "") {
		$sqlquery .= "description = $args{description},";		
	}
	if (defined($args{projectManagerId}) && $args{projectManagerId} ne "" && $args{projectManagerId} != 0) {
		$sqlquery .= "project_manager_id = $args{projectManagerId},";		
	}
	if (defined($args{requirementsManagerId}) && $args{requirementsManagerId} ne "" && $args{requirementsManagerId} != 0) {
			$sqlquery .= "requirements_manager_id = $args{requirementsManagerId},";		
	}
	if (defined($args{configurationManagerId}) && $args{configurationManagerId} ne "" && $args{configurationManagerId} != 0) {
			$sqlquery .= "configuration_manager_id = $args{configurationManagerId},";		
	}
	if ($sccbid) {
			$sqlquery .= "sccbid = $args{sccbid},";		
	} else {$sqlquery .= "sccbid = NULL,";}
	chop($sqlquery);
	$sqlquery .= " WHERE id = $args{projectId}";

	$args{dbh}->do($sqlquery);
	&log_activity($args{dbh},$args{schema},$args{userId},"Project $name updated");
	return ($args{projectId});
}

###################################################################################################################################
sub getProjectSCCB {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $sccbid = $args{dbh}->selectrow_array("select sccbid from $args{schema}.project where id = $args{id}");
   
   if (defined($sccbid)) {return ($sccbid);}
   else {return 0;}
}

###################################################################################################################################
sub getSCCBName {                                                                                                              #
###################################################################################################################################
   my %args = (
      @_,
   );
   my $sccbname = $args{dbh}->selectrow_array("select name from $args{schema}.sccb where id = $args{id}");
   
   return ($sccbname);

}

###################################################################################################################################
sub getSCCBNames {                                                                                                              #
###################################################################################################################################
   my %args = (
      orderBy => 'name',
      @_,
   );
   tie my %SCCBList, "Tie::IxHash";
   my $csr = $args{dbh}->prepare ("select id, name from $args{schema}.sccb $args{where} order by $args{orderBy}");
   $csr->execute;
   while (my ($id, $name) = $csr->fetchrow_array) {
      $SCCBList{$id} = $name;
   }
   $csr->finish;
   return (\%SCCBList);

}
##########################################
1; #return true

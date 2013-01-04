#!/usr/local/bin/perl

{

  @TestVals = ("0".."9","a".."z");
  $looptest = "notdone";
  srand (time|$$);
  $KeyID = "";
    for ($pos = 0; ($pos < 32); $pos++) {
      $KeyID = $KeyID . $TestVals [rand (36)];
    }
  print "".$KeyID."\n";
}


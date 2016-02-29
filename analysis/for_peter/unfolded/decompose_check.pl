#!/usr/local/ActivePerl-5.6/bin/perl -w
#use strict

@residue{"a","c","d","e","f","g","h","i","k","l","m","n","p","q","r","s","t","v","w","y"}=("ALA","CYS","ASP","GLU","PHE","GLY","HIS","ILE","LYS","LEU","MET","ASN","PRO","GLN","ARG","SER","THR","VAL","TRP","TYR");

   @residue=sort(keys%residue);
   for($i=0;$i<=@residue-1;$i++){
             $target=$residue{$residue[$i]};
             print "$target\n";
             main();
   }

sub get{
  open(TEST,">test");
  print TEST "\n";
  print TEST "\n";
  
  open(DATA,"$target/$target.de.out");
  $open=0;
  while(<DATA>){
    chomp;
    if(/NSTEP/){
      $open++;
    }    
       if($open>0){
         print TEST "$_\n";@word5=split;
           if(/BOND/){
	       $bond=$word5[2];         $angle=$word5[5];     $dihed=$word5[8];
	   }elsif(/VDWAALS/){
	       $vdwaals=$word5[2];      $eeel=$word5[5];       $egbb=$word5[8];
	   }elsif(/1-4 VDW/){
	       $vdwaals_14=$word5[3];   $eel_14=$word5[7];     #$restraint=$word5[10];
	   }elsif(/ESURF/){
	       $esurf=$word5[2]; 
	   }	
	         
	 if(/ESURF/){
	   goto BYE;
	 }
       }
    
  }
  BYE:close DATA;
  close TEST;
    
     print `diff test $target/mdinfo>testt\n`;
     $line=0;
     $line=`wc -l < testt`;
     chomp($line);
     if($line != 0){
          die;
     }
         
}

sub decompose{

 if( -e "$target/$target\_statistics.out"){
 open (STA, "$target/$target\_statistics.out") || die "$target\_statistics.out";  
 $line=0;
 
  $int=0;$vdw=0;$eel=0;$gas=0;$egb=0;$gbsur=0;$gbsol=0;$gbtot=0;
  while(<STA>){
    chomp;
    @word4=split;$line++;
    
     if(   ($line >=5)  && (@word4>1) ){
        $int=$int+$word4[6];
	$vdw=$vdw+$word4[12];
	$eel=$eel+$word4[18];
        $gas=$gas+$word4[24];
	$egb=$egb+$word4[30];
	
	
        $gbsur=$gbsur+$word4[36];
	$gbsol=$gbsol+$word4[42];
	$gbtot=$gbtot+$word4[48];
     }
  }
  close STA;
  
  $intt=$bond+$angle+$dihed;
  
  print "INT $int $intt\n";                                        $diff=abs($int-$intt);    if($diff > 1)  {die;};

  $vdww=$vdwaals+$vdwaals_14;

  print "VDW $vdw $vdww\n";                                        $diff=abs($vdw-$vdww);    if($diff > 1) {die;};
  
  $eeel=$eeel+$eel_14;
 
  print "EEL $eel $eeel\n";                                        $diff=abs($eel-$eeel);    if($diff > 1)  {die;};

  $gass=$intt+$vdww+$eeel;
  
  print "GAS $gas $gass\n";                                        $diff=abs($gas-$gass);    if($diff > 1)  {die;};

  print "EGB $egb $egbb\n";                                        $diff=abs($egb-$egbb);    if($diff > 1)  {die;};

  $k=$gbsur + $egb;  
  print "(EGBSOL) $gbsol <--> $k  =  (EGBSUR) $gbsur + (EGB) $egb\n";$diff=abs($gbsol-$k);    if($diff > 1)  {die;};


  $k=$gbsol + $gass;
  print "(EGBTOT) $gbtot <--> $k  =  (EGBSOL) $gbsol + (GAS) $gass\n"; $diff=abs($gbtot-$k);    if($diff > 1)  {die;};
  }else{
    print "could not open $target\_statistics.out\n";
    die;
  }

}


sub main{
    	          		   
		   get();
		   decompose();
		   print "------------------------------------------------------------------------------------------\n";	
}
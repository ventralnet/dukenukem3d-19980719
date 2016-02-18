#!/usr/local/bin/perl
##############################################################################
# Counter                       Version 1.1.1                                #
# Copyright 1996 Matt Wright    mattw@worldwidemart.com                      #
# Created 10/27/95              Last Modified 4/25/96                        #
# Scripts Archive at:           http://www.worldwidemart.com/scripts/        #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1996 Matthew M. Wright  All Rights Reserved.                     #
#                                                                            #
# Counter may be used and modified free of charge by anyone so long as       #
# this copyright notice and the comments above remain intact.  By using this #
# code you agree to indemnify Matthew M. Wright from any liability that      #  
# might arise from it's use.                                                 #  
#                                                                            #
# Selling the code for this program without prior written consent is         #
# expressly forbidden.  In other words, please ask first before you try and  #
# make money off of my program.                                              #
#                                                                            #
# Obtain permission before redistributing this software over the Internet or #
# in any other medium.	In all cases copyright and header must remain intact.#
##############################################################################
# Define Variables

	### FILE AND DIRECTORY LOCATIONS, REFERERS ###

$count_file = "/path/to/count.txt";
$digit_dir = "/path/to/digit_dir";
$access_log = "/path/to/access_log";
$error_log = "/path/to/error_log";

$flyprog = "/path/to/fly/fly -q";
$fly_temp = "/path/to/fly_temp.txt";

$bad_referer_img = "http://www.host.com/path/to/bad_referer.gif";

@referers = ("www.worldwidemart.com","worldwidemart.com","206.31.72.203");

	### IMAGE SETTINGS ###

$width = "24";
$height = "28";

$tp = "X";
$il = "1";

$frame_width = "8";
$frame_color = "0,0,0";

$dot = "X";
$logo = "X";

	### OPTIONS ###

$uselog = "1";	# 1 = YES; 0 = NO

# Done
##############################################################################

# Get the Date For Logging Purposes
if ($uselog == 1) {
   ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   if ($sec < 10)  { $sec = "0$sec";   }
   if ($min < 10)  { $min = "0$min";   }
   if ($hour < 10) { $hour = "0$hour"; }
   if ($mday < 10) { $mday = "0$mday"; }
   if ($mon < 10)  { $monc = "0$mon";  }
   $date = "$hour\:$min\:$sec $mon/$mday/$year";
}

# Make Sure People Aren't Messing With the Counter From Other Web Pages
&check_referer;

# Get the Counter Number And Write New One to File
&get_num;

# If they Just want a transparent dot or a logo, give them that.
&check_dot;

# Determine Length of Counter Number
$num = $length = length($count);

# Set Individual Counter Numbers Into Associative Array
while ($num > 0) {
   $CHAR{$num} = chop($count);
   $num--;
}

# Determine the Height and Width of the Image
$img_width = (($width * $length) + ($frame_width * 2));
$img_height = (($frame_width * 2) + $height);

# Open the In-File for Commands
open(FLY,">$fly_temp") || die "Can't Open In File For FLY Commands: $!\n";

# Create New Counter Image
print FLY "new\n";
print FLY "size $img_width,$img_height\n";

# If User Wants Frame, Print Commands to the In-File
&make_frame;

# Copy Individual Counter Images Commands to In-File
$j = 1;
while ($j <= $length) {
   print FLY "copy $insert_width,$insert_height,-1,-1,-1,-1,$digit_dir/$CHAR{$j}\.gif\n";
   $insert_width = ($insert_width + $width); 
   $j++;
}

# If they want a color transparent, make it transparent
if ($tp ne "X" && $tp =~ /.*,.*,.*/) {
   print FLY "transparent $tp\n";
}

# If they want the image interlaced, make it interlaced
if ($il == 1) {
   print FLY "interlace\n";
}

# Close FLY
close(FLY);

$output = `$flyprog -i $fly_temp`;
print "Content-type: image/gif\n\n";
print "$output";

# Remove Temp File
unlink($fly_temp);

# Log the Counter Access
if ($uselog == 1) {
   &log_access;
}

sub check_referer {
   if (@referers && $ENV{'HTTP_REFERER'}) {
      foreach $referer (@referers) {
         if ($ENV{'HTTP_REFERER'} =~ /$referer/) {
            $ref = 1;
            last;
         }
      }
   }
   else {
      $ref = 1;
   }

   if ($ref != 1) {
      print "Location: $bad_referer_img\n\n";

      if ($uselog == 1) {
         open(LOG,">>$error_log") || die "Can't Open User Error Log: $!\n";
         print LOG "$error: $ENV{'REMOTE_HOST'} [$date] $ENV{'HTTP_REFERER'} - $ENV{'HTTP_USER_AGENT'}\n";
         close(LOG);
      }

      exit;
   }
}

sub get_num {
   open(COUNT,"$count_file") || die "Can't Open Count Data File: $!\n"; 
   $count = <COUNT>;
   close(COUNT);
   if ($count =~ /\n$/) {
      chop($count);
   }

   $count++;

   open(COUNT,">$count_file") || die "Can't Open Count Data File For Writing: $!\n";
   print COUNT "$count";
   close(COUNT);
}

sub check_dot {

   if ($dot == 1) {
      # Open the In-File for Commands
      open(FLY,">$fly_temp") || die "Can't Open In File For FLY Commands: $!\n";

      # Create New Counter Image
      print FLY "new\n";
      print FLY "size 1,1\n";
      print FLY "fill x,y,0,0,0\n";
      print FLY "transparent 0,0,0\n";
      close(FLY);

      $output = `$flyprog -i $fly_temp`;
      print "Content-type: image/gif\n\n";
      print "$output";

      exit;
   }
   elsif ($logo ne "X" && $logo =~ /.*tp:\/\//) {
      print "Location: $logo\n\n";

      # Log The Access
      if ($uselog == 1) {
         &log_access;
      }

      exit;
   }
}

sub make_frame {
   $insert_width = $insert_height = $frame_width;

   $insert_frame = 0;

   while ($insert_frame < $frame_width) {
      $current_width = ($img_width - $insert_frame);
      $current_height = ($img_height - $insert_frame);
 
      print FLY "line 0,$insert_frame,$img_width,$insert_frame,$frame_color\n";
      print FLY "line $insert_frame,0,$insert_frame,$img_height,$frame_color\n";
      print FLY "line $current_width,0,$current_width,$img_height,$frame_color\n";
      print FLY "line $current_height,0,$current_height,$img_width,$frame_color\n";

      $insert_frame++;
   }
}

sub log_access {
   open(LOG,">>$access_log") || die "Can't Open User Access Log: $!\n";
   print LOG "[$date] $ENV{'HTTP_REFERER'} - $ENV{'REMOTE_HOST'} -  $ENV{'HTTP_USER_AGENT'}\n";
   close(LOG);
}

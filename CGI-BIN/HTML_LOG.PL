#! /usr/local/bin/perl
##############################################################################
# HTML Log                      Version 1.0                                  #
# Copyright 1996 Matt Wright    mattw@worldwidemart.com                      #
# Created 10/25/95              Last Modified 10/26/95                       #
# Scripts Archive at:           http://www.worldwidemart.com/scripts/        #
# The file STAT_README contains more information. For Use With Counter 1.1.1 #
##############################################################################
# COPYRIGHT NOTICE                                                           #
# Copyright 1996 Matthew M. Wright  All Rights Reserved.                     #
#                                                                            #
# HTML Log may be used and modified free of charge by anyone so long as      #
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

$log_file = "/path/to/access_log";

$web = "1";

$min_refs = "5";
$min_remote = "15"; 
$min_agent = "5";

##############################################################################
# Select Options

$expand_agent = 0;      # 0 = NO; 1 = YES
$show_percent = 1;      # 0 = NO; 1 = YES

$title = "Matt's Script Archive";
$title_url = "http://worldwidemart.com/scripts/";

# Done
##############################################################################

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
if ($sec < 10)  { $sec = "0$sec";   }
if ($min < 10)  { $min = "0$min";   }
if ($hour < 10) { $hour = "0$hour"; }
if ($mday < 10) { $mday = "0$mday"; }
if ($mon < 10)  { $monc = "0$mon";  }

if ($web == 1) {
   print "Content-type: text/html\n\n";
}

$date_now = "$hour\:$min\:$sec $mon/$mday/$year";

open(DB,"$log_file") || die "Cannot Open Log File $log_file: $!";
@lines = <DB>;
close(DB);

$accesses = @lines;

if ($lines[1] =~ /\[(.*)\] (.*) - (.*) - (.*)/) {
   $first_date = $1;
}
else {
   $first_date = 0;
}

if ($lines[($accesses - 1)] =~ /\[(.*)\] (.*) - (.*) - (.*)/) {
   $last_date = $1;
}
else {
   $last_date = 0;
}

foreach $line (@lines) {
   if ($line =~ /\[(.*)\] (.*) - (.*) - (.*)/) {
      $date = $1;
      ($clock,$time,$day) = split(/ /,$date);
      ($hour,$minute,$second) = split(/:/,$clock);
      $referer = $2;
      $referer =~ s/\%24/\$/g;
      $referer =~ s/\%7E/~/g;
      $remote_host = $3;
      $user_agent = $4;

      if ($time eq 'PM') {
         $hour += 12;
      }

      if ($day ne '' && $day ne ' ') {
         push(@DAYS, $day);
      }
      if ($hour ne '' && $hour ne ' ') {
         push(@HOURS, $hour);
      }
      if ($referer ne 'No Referer' && $referer ne ' ' && $referer ne '') {
         push(@REFERER, $referer);
      }
      if ($remote_host ne 'No Remote_Host' && $remote_host ne ' ' && $remote_host ne '') {
         push(@REMOTE_HOST, $remote_host);
      }
      if ($user_agent ne 'No User_Agent' && $user_agent ne ' ' && $user_agent ne '') {
         push(@USER_AGENT, $user_agent);
      }
   }
}

foreach (@REFERER) {
   $refs{($_)[0]}++;
   $i++;
}

foreach (@REMOTE_HOST) {
   $remote{($_)[0]}++;
   $j++;
}

foreach (@USER_AGENT) {
   if ($expand_agent == 1) {
      $agent{($_)[0]}++;
   }
   else {
      $agent{(split('/',$_))[0]}++;
   }
   $k++;
}

foreach (@DAYS) {
   $day{($_)[0]}++;
}

foreach (@HOURS) {
   $hour{($_)[0]}++;
}

&html_header;

sub html_header {
   print "<html><head><title>Access Stats for $title</title></head>\n";
   print "<body><center><h1>Access Stats for $title</h1></center>\n";
   print "Below are the access stats for $title.<p>\n";
   print "A total of $accesses were reviewed for this logging, which occurred at: $date_now<p>\n";
   if ($first_date != 0 && $last_date != 0) {
      print "These statistics reflect accesses from: <i>$first_date</i> to <i>$last_date</i><p>\n";
   }
   print "<p><hr size=7 width=75%>\n";
   print "<font size=-1>[ <a href=\"\#refs\">Referring Web Pages</a> ] [ <a href=\"\#remote_host\">Remote Hosts</a> ] [ <a href=\"\#browsers\">Browsers</a> ] [ <a href=\"\#days\">Hits by Day</a> ] [ <a href=\"\#hours\">Hits by Hour</a> ] [ <a href=\"$titl




e_url\">$title</a> ]</font>\n";
   print "<hr size=7 width=75%><p>\n";

   &html_referer;
   &html_remote_host;
   &html_user_agent;
   &days;
   &hours;
}

sub html_referer {
   print "<center><h2><a name=\"refs\">Referring Web Pages</a></h2></center>\n";
   print "<b>Referring URLs Searched:</b> <i><u>$i</u></i><br>\n";
   print "<b>Minimum References Required to Make List:</b> $min_refs</u></i><p>\n";

   print "<table border width=100%>\n";
   if ($show_percent == 1) {
      print "<tr><th>Number </th><th>Percent </th><th>Referring Web Sites<br></th></tr>\n";
   }
   else {
      print "<tr><th>Number </th><th>Referring Web Sites<br></th></tr>\n";
   }
   foreach (sort { $refs{$b} <=> $refs{$a} } keys %refs) {
      if ($refs{$_} >= $min_refs) {
         print "<tr>\n";
         $total_refs += $refs{$_};
         if ($show_percent == 1) {
            $percent_refs = (int(10000 * ($refs{$_} / $i)) / 100);
            $total_percent_refs += $percent_refs;
            print "<th>$refs{$_} </th><th>$percent_refs\% </th><td><a href=\"$_\">$_</a><br></td>\n";
         }
         else {
            print "<th>$refs{$_} </th><td><a href=\"$_\">$_</a><br></td>\n";
         }
         print "</tr>\n";
      }
   }
   if ($show_percent == 1) {
      print "<tr><th>$total_refs </th><th>$total_percent_refs\% </th><th>Totals For URLS Shown<br></th></tr>\n";
   }
   else {
      print "<tr><th>$total_refs </th><th>Totals For URLS Shown<br></th></tr>\n";
   }
   print "</table><hr size=7 width=75%><p>\n";
}

sub html_remote_host {
   print "<center><h2><a name=\"remote_host\">Remote Hosts</a></h2></center>\n";
   print "<b>Remote Hosts Searched:</b> <u><i>$j</i></u><br>\n";
   print "<b>Minimum Hits Required to Make List:</b> <i><u>$min_remote</u></i><p>\n";

   print "<table border>\n";
   if ($show_percent == 1) {
      print "<tr><th>Number of Hits </th><th>Percent </th><th>Remote Hosts<br></th></tr>\n";
   }
   else {
      print "<tr><th>Number of Hits </th><th>Remote Hosts<br></th></tr>\n";
   }
   foreach (sort { $remote{$b} <=> $remote{$a} } keys %remote) {
      if ($remote{$_} >= $min_remote) {
         print "<tr>\n";
         if ($show_percent == 1) {
            $percent_remote = (int(10000 * ($remote{$_} / $j)) / 100);
            print "<th>$remote{$_} </th><th>$percent_remote\% </th><td>$_<br></td>\n";
         }
         else {
            print "<th>$remote{$_} </th><td>$_<br></td>\n";
         }
         print "</tr>\n";
      }
   }
   print "</table><hr size=7 width=75%><p>\n";
}

sub html_user_agent {
   print "<a name=\"browsers\"><center><h2>WWW Browsers</h2></center></a>\n";
   print "<b>Browsers Searched:</b> <u><i>$k</i></u><br>\n";
   print "<b>Minimum Hits Required to Make List:</b> <u><i>$min_agent</i></u><p>\n";

   print "<table border>\n";
   if ($show_percent == 1) {
      print "<tr><th>Number of Hits </th><th>Percent </th><th>Browser<br></th></tr>\n";
   }
   else {
      print "<tr><th>Number of Hits </th><th>Browser<br></th></tr>\n";
   }

   foreach (sort { $agent{$b} <=> $agent{$a} } keys %agent) {
      if ($agent{$_} >= $min_agent) {
         print "<tr>\n";
         if ($show_percent == 1) {
            $percent_agent = (int(10000 * ($agent{$_} / $k)) / 100);
            print "<th>$agent{$_} </th><th>$percent_agent\% </th><td>$_<br></td>\n";
         }
         else {
            print "<th>$agent{$_} </th><td>$_<br></td>\n";
         }
         print "</tr>\n";
      }
   }
   print "</table>\n";
}

sub hours {
   print "<a name=\"hours\"><center><h2>Hits By Hour</h2></center></a>\n";
   print "<table border>\n";
   print "<tr><th>Hour </th><td>Number of Hits<br></td></tr>\n";
   foreach (sort keys %hour) {
      print "<tr>\n";
      print "<th>$_ </th><td>$hour{$_}<br></td>\n";
      print "</tr>\n";
   }
   print "</table>\n";
}

sub days {
   print "<a name=\"days\"><center><h2>Hits By Day</h2></center></a>\n";
   print "<table border>\n";
   print "<tr><th>Day </th><td>Number of Hits<br></td></tr>\n";
   foreach (sort keys %day) {
      print "<tr>\n";
      print "<th>$_ </th><td>$day{$_}<br></td>\n";
      print "</tr>\n";
   }
   print "</table>\n";
}

sub html_trailer {
   print "<p><hr size=7 width=75%>\n";
   print "<font size=-1>[ <a href=\"\#refs\">Referring Web Pages</a> ] [ <a href=\"\#remote_host\">Remote Hosts</a> ] [ <a href=\"\#browsers\">Browsers</a> ] [ <a href=\"$title_url\">$title</a> ]</font>\n";
   print "<hr size=7 width=75%><p>\n";
   print "</body></html>\n";
}

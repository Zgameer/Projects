#!/usr/bin/perl
#Created by Tyler Rasmussen

#The purpose of this program was originally to help a friend parse over some files to check for specific
#occurences of websites across html and other web files (mainly to check if there were existing malicious links and what not
#for a project he was working on). I decided to flesh it out a bit. I'm very sure there are plenty of other
#tools out there that do everything this one does (grep probably does all of it) but this was just for fun and experience.


#as the nature of this program means that there can be long wait times, it might be nice to know how long execution took
#this is done at the bottom

#make sure we are provided the proper amount of arguments
$length = $#ARGV+1;

if ($length != 3)
{
    printf "\nUsage: compareWordlist.perl ";
    printf "'expr' <f> <d>\n\t";
    printf "expr: Regular expression to check filenames for (i.e. *.html, etc.)\n\t";
    printf "<f>: File of words/lines/urls/etc/ to check for\n\t";
    printf "<d>: Directory of files to check\n\n";
    exit(0);
}


#get our variables from ARGV
$expression = shift;
$filename = shift;
$directory = shift;

#get the files from the directory
@files = glob("$directory/$expression");
#open the file of compare words
open($fh, "<", $filename);
#read the compare words into a wordlist
@wordlist = <$fh>;
#close our file of compare words
close($fh);
#declare misc. variables
$i = 0;
$result = 0;
%hits;
%fileHits;
@arr;
%filesForWords;

#remove eroneous spaces from our lists
chomp(@wordlist);
chomp(@files);

#for each word in the wordlist
foreach $word (@wordlist)
{
    #for each file in the file list
    foreach $file (@files)
    {
        #open the current file
        open($fh2, "<", $file);
        #loop through the entire file and check regex against the lines
        while(<$fh2>)
        {
            #check regex
            if($_ =~ $word)
            { 
                $hits{$word}++;    #increments the number of hits for particular keys without reference to files
                $fileHits{$file}++;    #increments the number of hits for a particular file without reference to keys
                @arr[$i] = $file;    #adds this file to the files that the current word matches against
                $i++;       #increment the counter for the matched files arr @arr
                last;       #we only care to find a single match in the file, so leave the while loop for this file
            }
        }
    #close our file responsibly :)
    close($fh2);
    }
    #essentially flatten out the array of matched files into a hash for each word
    $filesForWords{$word} = join(", ", @arr);
    $i = 0;
    undef @arr;       #undefine and redefine the @arr to clear it out for the next read
    @arr;
}

printf("#######################BEGIN##########################\n");

#sort lists
@tmplist = sort @wordlist;
@wordlist = @tmplist;
@tmplist = sort @files;
@files = @tmplist;

#for each wordlist, make sure it actually had hits and print out the number of hits it had and what files it had hits in
foreach (@wordlist)
{
    if($hits{$_} < 1)
    {
        next;
    }
    printf "#####################NEW ENTRY########################\n";
    printf "Number of Hits for word %s: %d\n", $_, $hits{$_}; 
    printf "Files containing word:\n\n%s\n\n", $filesForWords{$_};  
}

printf("#######################HITS###########################\n");

#painstakingly sort this one as well
@fileHitsSorted;
$i = 0;
#for each file, print out how many hits it had, only notes total hits to the file with regards to the words in the list
foreach (@files)
{
    if($fileHits{$_} < 1)
    {
        next;
    }
    @fileHitsSorted[$i] = sprintf "Number of Hits for file %s: %d\n", $_, $fileHits{$_};  
    $i++;
}

@tmplist = sort @fileHitsSorted;
@fileHitsSorted = @tmplist;
undef @tmplist;

printf("@fileHitsSorted\n");


printf("#########################END##########################\n");


#execution time
print "\nExecution completed in ";
print time - $^T;
print " second(s)\n\n";

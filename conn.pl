#!perl
#perl connect to mysql database

use DBI;
my $data_source = 'DBI:mysql:database=perl;host=localhost';
my $username = 'root';
my $password = '123456';
$dbh = DBI->connect($data_source, $username, $password);
#$dbh->do('insert into users(username,age) values("baobao",0)');
#!E:goss\projects\perl\getWebs
use strict;
use LWP::UserAgent;
#require 'getProxy.pl';
my $beginid = 201424;
my $endid   = 2696863;
my $per_num = 100000;
my $proxy = &getProxy;
my $num = 0;#抓取的数据条数
my $switch = 10;#抓取多少条数据后切换代理

my $filename = time();
open LOG,">txt/$filename.sql";

for(my $i=$beginid;$i<=$endid;$i++){
	
	my $ua = new LWP::UserAgent(agent => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.5) Gecko/20121824 Firefox/1.5.0.5');
	$ua->proxy([qw(http https)] => "http://$proxy");
	my $response = $ua->get("http://www.qjy168.com/shop/userinfo.php?userid=$i") or next;
	
	my $html = $response->content;
	#utf8::encode($html);

	#公司名称
	my @company = $html =~m/\<strong\>.*\<\/strong\>/g;
	#姓名
	my @name = $html =~m/^\<b\>.*\<\/b\>/g;

	#电话号码
	my @telephone = $html =~m/\d+(-|\s)\d+(-|\s)\d+-{0,1}\d{0,1}/ig;

	#手机号码
	my @mobie = $html =~m#15\d{9}|13\d{9}|18\d{9}#sg;
	
	#msn
	my @msn = $html =~m/[0-9a-zA-Z_]+\@[0-9a-zA-Z_]+\.[0-9a-zA-Z_]+/g;
	
	#过滤不需要的字符串
	@name[0] =~ s/\<b\>|\<\/b\>|\"//g;
	@company[0] =~ s/\<strong\>|\<\/strong\>|\"//ig;
	@company[0] =~ s/\<td\s{0,1}.*Ttitel16\>|\<\/td\>//ig;
	
	my $uname = @name[0];
	my $ucompany = @company[0];
	my $utelephone = @telephone[0];
	my $umobie = @mobie[0];
	my $umsn = @msn[0];
	
	print "getting the $i th infomation of @company\r\n";
	#syswrite(LOG,"$ucompany\t$uname\t$utelephone\t$umobie\t$umsn\r\n");
	my $sql = "insert into users(qid,name,company,telephone,mobie,msn)values($i,\"$uname\",\"$ucompany\",\"$utelephone\",\"$umobie\",\"$umsn\");";
		
	if($ucompany){
		syswrite(LOG,"$sql\r\n");
	}
	if($i%$per_num==0){
		$num ++;
		close LOG;
		open LOG,">txt/$filename.sql";
	}
	#切换代理
	if($num%$switch==0){
		$proxy = &getProxy;
	}
	
}

sub getProxy{
	my @proxy_accounts = {};
	my $proxy_file = 'proxy.txt';
	open PROXY,"$proxy_file";
	
	while(<PROXY>){
		chomp($_);
		push(@proxy_accounts,$_);
		#print $_;
	}
	my $count = @proxy_accounts;
	my $rand = int(rand($count-2));
	@proxy_accounts[$rand];
}
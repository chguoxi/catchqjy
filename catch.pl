#!E:goss\projects\perl\getWebs
#抓取远程网站的内容

use Encode;
use LWP::RobotUA;
use utf8; 

#开始扫描的id号
my $beginid         = 2185172;
#结束的id号
my $endid           = 2696863;
#每个文件存放多少条数据
my $per_num         = 100000;
my $current_num     = 0;
#爬行每个网址休眠的时间
my $delay_time = 1/60;
my $filename        = time();
#以当前时间戳生成文件名
open LOG,">txt/$filename.sql";
my $ua = LWP::RobotUA->new('Baiduspider/2.1', 'Baiduspider@baidu.com');
$ua->delay($delay_time);
#抓取过快被拒绝的时候自动休眠
$ua->use_sleep( true );

for(my $i=$beginid;$i<=$endid;$i++){
	
	my $response = $ua->get("http://www.qjy168.com/shop/userinfo.php?userid=$i") or next;
	
	my $html = $response->content;
	#utf8::encode($html);

	#公司名称
	my @company = $html =~m/\<strong\>.*\<\/strong\>/g;
	#姓名
	my @name = $html =~m/\<b\>.*\<\/b>/g;

	#电话号码
	my @telephone = $html =~m/\d{2,4}-\d{2,4}-\d{6,11}-{0,1}\d{0,3}|\d{2,4}\s\d{2,4}\s\d{6,11}\s{0,1}\d{0,3}/ig;

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
	
	my $sql = "insert into users(qid,name,company,telephone,mobie,msn)values($i,\"$uname\",\"$ucompany\",\"$utelephone\",\"$umobie\",\"$umsn\");";
		
	if($ucompany){
		syswrite(LOG,"$sql\r\n");
		$current_num ++;		

	}
	if($current_num%$per_num==0){
		close LOG;
		open LOG,">txt/".time().'.sql';
	}
}

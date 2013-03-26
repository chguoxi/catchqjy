#!E:goss\project\perl\getWebs
#抓取远程网站的内容

use Encode;
use LWP::Simple;
use utf8; 

#开始扫描的id号
my $beginid         = 100001;
#结束的id号
my $endid           = 2696863;
#当前抓取的数据条数
my $current_num     = 0;
#每抓取多少条数据休眠一次
my $sleep_frequency =298;
#每个文件存放多少条数据
my $per_num         = 100000;
my $filename        = time();
#以当前时间戳生成文件名
open LOG,">txt/$filename.sql";

for($i=$beginid;$i<=$endid;$i++){
	my $url = "http://www.qjy168.com/shop/userinfo.php?userid=$i";
	my $html = get( "$url" ) || next;
	utf8::encode($html);
	#公司名称
	@company = $html =~m/\<strong\>.*<\/strong\>/g;
	#姓名
	@name = $html =~m/\<b\>.*\<\/b\>/g;
	#电话号码
	@telephone = $html =~m/\d+-\d{2,4}-\d{6,11}|\d+\s\d{2,4}\s\d{6,11}/ig;
	#手机号码
	@mobie = $html =~m#15\d{9}|13\d{9}|18\d{9}#sg;

	@msn = $html =~m/[0-9a-zA-Z_]+\@[0-9a-zA-Z_]+\.[0-9a-zA-Z_]+/g;
	
	@name[0] =~ s/\<b\>|\<\/b\>//ig;
	@company[0] =~ s/\<strong\>|\<\/strong\>//ig;
	
	$uname      = @name[0];
	$ucompany   = @company[0];
	$utelephone = @telephone[0];
	$umobie     = @mobie[0];
	$umsn       = @msn[0];
	
	print "is getting the $i th items telephone number :$utelephone\r\n";
	
	$sql = "insert into users(qid,name,company,telephone,mobie,msn)values($i,'$uname','$ucompany','$utelephone','$umobie','$umsn');";
	
	$current_num ++;
	#如果公司名不为空,则断定这是一条有效的信息
	if( $ucompany ){
		syswrite(LOG,$sql);
	}
	
	#文件写满了,新建另外一个文件
	if( $current_num % $per_num==0 ){
		close LOG;
		open LOG,">txt/$filename.sql";
	}
	
	#进入休眠状态
	if( $current_num % $sleep_frequency==0 ){
		print 'sleeping...\r\n';
		sleep(1800);
	}
}

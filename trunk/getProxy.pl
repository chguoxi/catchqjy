#!E:goss\projects\perl\getWebs
#获取随机代理
sub getProxy{
	@proxy_accounts = {};
	my $proxy_file = 'proxy.txt';
	open PROXY,"$proxy_file";
	
	while(<PROXY>){
		chomp($_);
		push(@proxy_accounts,$_);
		#print $_;
	}
	$count = @proxy_accounts;
	$rand = int(rand($count-2));
	return @proxy_accounts[$rand];
}
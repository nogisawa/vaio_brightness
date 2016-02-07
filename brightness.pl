#!/usr/bin/perl

# パラメーターを$paramへ代入
my $param = $ARGV[0];
print "param : $param\n";

# 汎用カウンタ
my $cnt = 0;

# ブライトネスの値を設定するファイルを指定
$file_path = "/sys/class/backlight/intel_backlight/brightness";

# ブライトネスの取得
open( FH, "+< ${file_path}") or die("FileOpenError: $!");
my $now_value = <FH>;
chomp($now_value);

# ブライトネスのステップリスト
# この部分を加えたり削除したりする事でブライトネスの段階を変更できる。
# ちなみに0はバックライト消灯になる
my @brightness = (
    0       ,
    491385  ,
    982770  ,
    1474155 ,
    1965540 ,
    2456925 ,
    2948310 ,
    3439695 ,
    3931080 ,
    4422465 ,
);

my $step = @brightness;

print "step: $step\n";
print "now: $now_value\n";

# search now setting
$margin->{amount} = $brightness[$step-1];
$margin->{id}     = $step;

print "MAX $margin->{amount}\n";

for ( $cnt=0; $cnt<$step; $cnt++  ){

    if( $margin->{amount} > abs($now_value - $brightness[$cnt]) ){

	$margin->{id}    = $cnt;
	$margin->{amount}= abs( $now_value - $brightness[$cnt] );
	
    }    
    
}

my $new_step = $now_value;

if( $param eq 'up' ){

    if( $margin->{id} < $step-1  ){

	$new_step = $brightness[ $margin->{id} +1  ];

    }
	
}elsif( $param eq 'down' ){

    if( $margin->{id} > 0 ){
    
	$new_step = $brightness[ $margin->{id} -1  ];

    }
}elsif( $param =~ /\d{1,16}/ && 0 <= $param && $param <= $step  ){

    $new_step = $param;

}elsif( $param =~ /^\d{1,16}%$/ ){

    $param =~ /(^\d{1,3})%$/;
    my $new_step_percent = $1;
    print "( $new_step_percent  / 100 )\n";
    $new_step = $brightness[$step-1] * ( $new_step_percent  / 100 );

    if( $new_step =~ /^(\d+)\.\d+$/  ){ $new_step = $1 }
    
}else{

    print "Invalid Parameter.\n";
    
}


# dont change, no change values

if( $new_step != $now_value  ){

    print "writing new value.($new_step)\n";
    print FH "$new_step";
    
}

close(FH);

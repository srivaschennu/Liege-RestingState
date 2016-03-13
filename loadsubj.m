newpatlist = {
    '52'
    '61'
    '63'
    '65'
    '69'
    '58'
    '64'
    '78'
    '85'
    '97'
    '115'    
    };

patlist = {
    %'N','Adm diag','CRS Diag','PET','tennis','TBI?','Age','male','days onset','Outcome' 'CRS-R score'
    '1'     	1		0		1		0		0		49		1		2884	3		10
    '2'         1		1		1		NaN		0		27		0		1570	4		15
    '3'         0		1		1		NaN		1		27		1		1542	NaN		10
    '4'         0		0		0		0		0		73		1		86		1		7
    '5'         0		0		0		NaN		0		35		1		6950	2		7
    '6'         NaN		1		1		0		0		60		1		9		1		3
    '7'         1		1		1		0		1		24		1		319		3		10
    '8'         0		0		0		NaN		0		29		1		738		1		7
    '9'         0		1		1		NaN		0		30		0		2406	NaN		9
    '10'		NaN		1		1		NaN		1		18		1		NaN		1		12
    '11'		1		1		1		0		1		30		0		563		3		6
    '12'		0		1		1		0		1		30		1		583		3		11
    '13'		0		1		1		NaN		1		50		1		NaN		2		13
    '14'		NaN		1		1		NaN		1		30		0		NaN		3		11
    '15'		0		0		1		0		1		22		1		180		3		9
    '16'		0		1		1		1		1		46		1		528		3		13
    '17'		1		1		1		1		0		48		0		NaN		3		8
    '18'		0		1		1		1		0		37		1		1869	NaN		11
    '19'		NaN		1		1		NaN		0		59		0		NaN		1		9
    '20'		NaN		1		1		NaN		1		5		0		NaN		3		16
    '21'		0		0		0		0		1		31		0		843		NaN		6
    '23'		1		1		1		NaN		0		30		1		33		2		17
    '24'		1		1		1		NaN		1		43		1		3139	NaN		8
    '25'		0		0		1		0		0		45		0		491		4		7
    '26'		0		1		0		0		0		57		1		390		2		8
    '27'		0		1		1		1		0		25		0		308		NaN		8
    '29'		0		0		0		0		0		59		1		1210	2		6
    '30'		1		1		1		NaN		1		23		1		421		5		13
    '31'		0		0		0		0		0		28		1		66		2		8
    '33'		1		1		1		1		0		66		0		11		7		8
    '35'		1		1		1		NaN		0		53		1		1235	NaN		12
    '36'		1		1		1		NaN		1		24		1		NaN		3		17
    '37'		NaN		0		0		0		1		26		1		480		2		7
    '38'		0		0		1		1		0		36		0		NaN		3		4
    '39'		1		1		1		NaN		1		54		0		196		3		16
    '40'		1		1		1		0		1		22		1		2972	NaN		14
    '41'		1		1		1		0		1		23		1		2035	3		17
    '42'		1		1		1		NaN		0		73		1		28		1		10
    '43'		NaN		1		1		0		1		23		1		639		3		14
    '44'		NaN		1		1		1		1		30		1		3337	NaN		14
    '46'		1		1		1		1		0		47		0		NaN		1		6
    '47'		0		1		1		1		1		65		1		674		1		9
    '48'		0		1		1		NaN		1		38		0		293		3		6
    '50'		1		1		1		0		0		55		1		NaN		3		17
    '51'		NaN		1		1		0		0		7		1		1476	NaN		16
    '52'		1		2		1		NaN		1		57		1		1398	NaN		16 %noisy
    '53'		0		1		1		NaN		1		19		1		426		NaN		11
    '54'		3		3		1		NaN		0		52		1		143		NaN		NaN
    '56'		1		1		1		NaN		1		18		0		118		NaN		13
    '57'		1		1		1		NaN		1		39		0		1437	NaN		11
    '58'		1		2		1		NaN		1		34		0		375		NaN		23
    '59'		1		1		1		NaN		0		61		0		858		NaN		17
    '60'		0		0		0		NaN		0		40		0		815		NaN		6 %noisy
    '61'		0		2		1		NaN		1		37		1		6177	NaN		23 % very noisy
    '62'		1		1		NaN		NaN		0		22		1		1211	NaN		10
    '63'		NaN		2		1		NaN		1		32		1		845		NaN		23 %very noisy
    '64'		NaN		2		0		NaN		0		37		1		263		NaN		23
    '65'		NaN		2		NaN		NaN		0		14		1		185		NaN		19 %very noisy
    '67'		1		0		1		NaN		0		26		0		112		NaN		6
    '68'		1		1		1		NaN		0		35		1		4154	NaN		12
    '69'		1		2		1		NaN		0		60		1		406		NaN		23 %noisy
    '71'		0		0		0		NaN		0		62		1		672		NaN		5
    '72'		NaN		1		1		1		0		67		0		1464	NaN		11
    '73'		1		1		1		NaN		1		32		0		657		NaN		15
    '74'		3		3		1		0		1		54		0		2122	NaN		17
    '75'		0		0		0		NaN		0		23		1		456		NaN		9
    '76'		1		1		1		NaN		0		42		0		220		NaN		8
    '77'		1		0		0		NaN		0		35		0		398		NaN		8
    '78'		NaN		2		NaN		NaN		0		63		0		168		NaN		15
    '79'		0		1		0		0		1		32		1		655		NaN		13
    '80'		1		1		1		NaN		0		72		1		3062	NaN		12
    '81'		1		1		1		NaN		1		24		1		528		NaN		13
    '82'		1		1		1		NaN		1		19		0		1304	NaN		9
    '83'		0		0		1		NaN		1		21		1		257		NaN		7
    '84'		NaN		1		1		NaN		1		30		1		402		NaN		9
    '85'		NaN		2		1		1		1		28		1		2423	NaN		21
    '86'		1		1		1		NaN		1		32		1		1009	NaN		8
    '87'		1		3		1		NaN		1		41		1		7387	NaN		20
    '88'		1		1		1		NaN		1		59		0		709		NaN		14
    '89'		0		0		0		NaN		0		51		0		347		NaN		7
    '90'		0		1		1		NaN		1		45		1		4778	NaN		11 %noisy
    '91'		1		1		1		0		1		25		1		1283	NaN		12
    '92'		0		1		1		NaN		0		21		1		508		NaN		7 %very noisy
    '93'		NaN		3		1		NaN		0		28		0		2130	NaN		NaN
    '94'		2		1		1		NaN		0		37		0		544		NaN		13
    '95'		0		1		1		NaN		0		45		1		138		NaN		11
    '96'		0		0		0		NaN		1		32		0		5378	NaN		9
    '97'		1		2		1		NaN		1		42		1		1186	NaN		21
    '98'		1		1		1		NaN		1		25		0		737		NaN		10 %very noisy
    '99'		1		1		1		NaN		1		59		1		1989	NaN		15
    '101'		0		1		1		NaN		0		24		0		333		NaN		11
    '102'		NaN		0		0		NaN		1		43		0		40		NaN		5
    '103'		0		0		NaN		NaN		0		56		1		170		NaN		7
    '104'		0		1		NaN		NaN		1		55		0		669		NaN		8
    '105'		1		1		1		0		0		39		1		252		NaN		18
    '106'		1		1		1		NaN		0		41		0		264		NaN		10
    '107'		1		1		1		NaN		0		54		0		252		NaN		16 %noisy
    '108'		1		1		1		NaN		0		54		1		387		NaN		12 %noisy
    '110'		0		1		1		NaN		1		38		1		541		NaN		16
    '111'		0		1		1		1		0		43		0		98		NaN		8
    '112'		0		1		1		0		1		22		1		423		NaN		12
    '113'		1		1		1		NaN		1		32		0		4681	NaN		16
    '114'		NaN		0		NaN		NaN		0		49		0		359		NaN		7
    '115'		3		2		1		NaN		0		33		0		308		NaN		22

% '22' %skipped - data error
% '28' %noisy
% '32'
% '34' %noisy
% '45' %not enough data
% '49'
% '55' %no data
% '66' %corrupt header
% '70' %only 255 channels
% '100' %no data
% '109' %very noisy
% '116' %corrupt data
% '117' no covariates
    };

% oldpatlist = {
%     'p0311_restingstate1'
%     'p0411_restingstate1'
%     'p1611_restingstate'
%     'p0510V2_restingstate'
%     'p1311_restingstate'
%     'p2011_restingstate'
%     'p0612_restingstate'
%     'p71v3_restingstate'
%     'p0712_restingstate'
%     'p0113_restingstate'
%     'p0313_restingstate'
%     'p0613_restingstate'
%     'p0812_restingstate1'
%     'p0611_restingstate'
%     'p0312_restingstate'
%     'p0211_restingstate1'
%     'p0511_restingstate'
%     'p0811_restingstate'
%     'p0911_restingstate'
%     'p1011_restingstate'
%     'p1511_restingstate'
%     'p1811_restingstate'
%     'p1911_restingstate'
%     'p0112_restingstate'
%     'p0212_restingstate'
%     'p0512_restingstate'
%     'p0710V2_restingstate'
%     'p0711_restingstate'
%     'p1711_restingstate'
%     'p1012_restingstate'
%     'p0213_restingstate'
%     'p0413_restingstate'
%     };

% ctrllist = {
% 'NW_restingstate'		2		2		2		2		2		2		2		2		10
% 'p37_restingstate'		2		2		2		2		2		2		2		2		10
% 'p38_restingstate'		2		2		2		2		2		2		2		2		10
% 'p40_restingstate'		2		2		2		2		2		2		2		2		10
% 'p41_restingstate'		2		2		2		2		2		2		2		2		10
% 'p42_restingstate'		2		2		2		2		2		2		2		2		10
% 'p43_restingstate'		2		2		2		2		2		2		2		2		10
% 'p44_restingstate'		2		2		2		2		2		2		2		2		10
% 'p45_restingstate'		2		2		2		2		2		2		2		2		10
% 'p46_restingstate'		2		2		2		2		2		2		2		2		10
% 'p47_restingstate'		2		2		2		2		2		2		2		2		10
% 'p48_restingstate'		2		2		2		2		2		2		2		2		10
% 'p49_restingstate'		2		2		2		2		2		2		2		2		10
% 'subj01_restingstate'		2		2		2		2		2		2		2		2		10
% 'subj02_restingstate'		2		2		2		2		2		2		2		2		10
% 'VS_restingstate'		2		2		2		2		2		2		2		2		10
% 'SS_restingstate'		2		2		2		2		2		2		2		2		10
% 'SB_restingstate'		2		2		2		2		2		2		2		2		10
% 'ML_restingstate'		2		2		2		2		2		2		2		2		10
% 'MC_restingstate'		2		2		2		2		2		2		2		2		10
% 'JS_restingstate'		2		2		2		2		2		2		2		2		10
% 'ET_restingstate'		2		2		2		2		2		2		2		2		10
% 'EP_restingstate'		2		2		2		2		2		2		2		2		10
% 'CL_restingstate'		2		2		2		2		2		2		2		2		10
% 'CD_restingstate'		2		2		2		2		2		2		2		2		10
% 'AC_restingstate'		2		2		2		2		2		2		2		2		10
%     };

% allsubj = cat(1,ctrllist,patlist);
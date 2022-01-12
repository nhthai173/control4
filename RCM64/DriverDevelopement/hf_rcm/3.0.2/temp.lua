
CASE1 = {
    '<CHECK_CONNE',
    'CTION,CONNECTED,3>',
    '<CHECK_CONNECTION,',
    'CONNECTED,3>',
    '<CHECK_CONNE',
    'CTION,CONNECTED,3>'
}


CASE2 = {
    '<CHECK_CONNECTIO',
    'N,CONNECTED,3>',
    '<RCM64V1,',
    '58,OPEN>',
    '<RCM64V1,59,OPEN>',
    '64V1,60,OPEN>',
    '<RCM',
    '<RCM64V1,61,',
    'OPEN>',
    '<RCM64V1,62,OPEN>',
    '<RCM64V',
    '1,63,OPEN>',
    '<RCM64V1,64,OPEN',
    '>',
    '<',
    'RCM64V1,65,OPEN>',
    '<RCME4V1,6',
    '6,OPEN>',
    '<RCM64V1,67,OPEN>',
    '<RCM6',
    '4V1,68,OPEN>',
    '<RCM64V1,69,OP',
    'EN>'

}



CASE3 = {
    'D,3>',
    '<RCM64V1,58,CLOSE',
    '>',
    '<',
    'RCM64V1,59,OPEN>',
    '<RCM64V1,6',
    '0,CLOSE>',
    '<RCM64V1,61,OPEN>',
    '4V1,62,CLOSE>',
    '<RCM64V1,63,CL',
    '<RCM6',
    'OSE>',
    [[<RCM64V1,
    64,
    CLOSE
    
    >
    ]],
    '<RCM64V1',
    ',65,CLOSE>',
    '<RCM64V1,66,OPEN>',
    '<R',
    'CM64V1,67,OPEN>',
    '<RCM64V1,68,O',
    'PEN>',
    '<RCM64V1,69,OPEN>'
}


CASE4 = {
    '<RCM64V1,66,OPEN>',
    '<RCM64V1',
    ',67,OPEN>',
    '<RCM64V1,68,OPEN>',
    '<RC',
    'M64V1,69,OPEN>'
}





local reStr = STR.join(CASE3)
reStr = reStr:gsub('%G', '')
kq, du = STR.split(reStr)
if(IsTableEmpty(kq))then
    print('[]')
else
    print(PrintTable(kq, '', true))
    print('============\nAfter:', du)
end
var
    times = 8,
    command =  'CLOSE',
    inline = '',
    onecom = '',
    total = 0

//MM: delay 100

function ff(con, o) {
    for(i=1; i<=o; i++){
        console.log(`<RCM64V1,DM,CON${con},C${i},NONE>`)
        console.log(`<RCM64V1,DM,CON${con},C${i},${command}>`)
        if (100 < Math.floor(Math.random()*100)) {
            console.log('<CHECK_CONNECTION>')
            total++
        }
        total += 2
    }
}

scon = 1
while(times > 0){
    if(times > 8)
        ff(scon,8)
    else
        ff(scon,times)
    scon++
    times -= 8
}

console.log('\n\nTotal commmands: '+total+'\n\n')
// <CHECK_CONNECTION>
//<RCM64V1,DM,{"PORT":["CON1"], "CON1": ["C1", "C2", "C3"]},CLOSE>
var
    times = 24,
    command =  'CLOSE',
    inline = '',
    onecom = '',
    total = 0

//MM: delay 100

function ff(con, o) {
    for(i=1; i<=o; i++){
        console.log(`<RCM64V1,MM,CON${con},C${i},NONE>`)
        console.log(`<RCM64V1,MM,CON${con},C${i},${command}>`)
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






/*
console.log('------------------')
console.log(onecom)
console.log('------------------')
console.log(inline)
console.log('------------------')
*/
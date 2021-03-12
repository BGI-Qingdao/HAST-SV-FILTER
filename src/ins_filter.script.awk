{
if (length($4)>=length($5)){
    print $0
  }
else {
    t=length($5);
    n=0;
    split($5,a,"");
    for(i=1;i<t;i++){
       if(a[i]=="N"){n+=1}
    }
    if(int(100*n/t)<T){ print $0}
  }
}

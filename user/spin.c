#include "kernel/types.h"
#include "user/user.h"

int main(){
    int pid;
    char c;
    pid=fork();
    if(pid!=0){
        c='1';
        printf("parent pid=%d ,child pid=%d\n",getpid(),pid);
    }else{
        c='0';
    }
    for(int i=0;;i++)
    {
        if (i%1000000==0){
            write(1,&c,1);
        }
    }
    
    exit(0);
}
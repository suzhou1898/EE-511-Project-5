p_arrival=input('Enter the probability that a new packet arrival p=');    %enter the arrival probability
k=input('Enter k=');
buffer_size=input('Enter buffer size=');
N=8;
n=10^6;
buffer(N,buffer_size+1)=zeros;
 
a=zeros(1,N);
a_cum=zeros(1  ,N);
num_drop=zeros(N,1);
outputport=zeros(N,1);
length_buffer=zeros(N,1);
HOL_block=zeros(N,1);
load=zeros(N,1);
 
a(1)=1/k;    %the probability of a new packet reaching each output port
for j=2:N
    a(j)=(1/(N-1))*((k-1)/k);
end
a_cum(1)=a(1);     %create probability array
for j=2:N
    a_cum(j)=a(j)+ a_cum(j-1);
end
a_cum;
for k=1:n
 
for i=1:N
    FIND=find(buffer(i,:)==0);
    if rand<p_arrival
        load(i,1)=load(i,1)+1;
        if ~isempty(FIND)   
            xr=rand;   %decide the destination of new arrived packet
            m=1;
            while xr>a_cum(m)
                m=m+1;
            end
        buffer(i,FIND(1))=m;
        
        else      %compute the packet drop
            num_drop(i,1)=num_drop(i,1)+1;
        end
    end
end
 
 
U=unique(buffer(:,1));   %forward packets in input port 
for i=1:length(U)
    if U(i)==0
        continue;
    else
        FIND=find(buffer(:,1)==U(i));
        if length(FIND)==1;
            outputport(U(i),1)=outputport(U(i),1)+1;
            for j=1:buffer_size
                buffer(FIND(1,1),j)=buffer(FIND(1,1),j+1);
                buffer(FIND(1,1),buffer_size+1)=0;
            end
        else
            outputport(U(i),1)=outputport(U(i),1)+1;
            inputport_rank=randperm(length(FIND));  %decide which port to send when there is a conflict
            num_chos=inputport_rank(1,1);
            FIND(num_chos,1);
            
            for j=1:buffer_size   %the packets are switched and forwarded
                buffer(FIND(num_chos,1),j)=buffer(FIND(num_chos,1),j+1);
                buffer(FIND(num_chos,1),buffer_size+1)=0;
            end
            
            for j=1:length(FIND)-1       %compute HOL blocks
                num_block=FIND(inputport_rank(1,j+1),1);
                HOL_block(num_block,1)=HOL_block(num_block,1)+1;
            end
end
    end
end
 
for i=1:N         %compute length of buffer occupied in each time slot
    for j=2:buffer_size+1
        if buffer(i,j)~=0
            length_buffer(i,1)=length_buffer(i,1)+1;
        end
    end
end
 
end
 
delay_portqueue=vpa((length_buffer/n)/p_arrival)   %compute throughput and delay
HOL_block=vpa((HOL_block/n)/p_arrival)
delay_queue=vpa(mean(delay_portqueue))
delay_HOL=vpa(mean(HOL_block))
delay_total=vpa(delay_queue+delay_HOL)
num_drop
outputport
num_drop=sum(num_drop)
throughput=sum(outputport)

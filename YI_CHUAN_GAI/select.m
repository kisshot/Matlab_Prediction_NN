
% select������ѡ��

function ret=select(individuals,popsize)
% �ú������ڽ���ѡ�����
% individuals input    ��Ⱥ��Ϣ
% sizepop     input    ��Ⱥ��ģ
% ret         output   ѡ��������Ⱥ
%����Ӧ��ֵ����  
fitness1=10./individuals.fitness; %individuals.fitnessΪ������Ӧ��ֵ
%����ѡ�����
sumfitness=sum(fitness1);
sumf=fitness1./sumfitness;
%�������̶ķ�ѡ���¸���
index=[];
for i=1:popsize   %popsizeΪ��Ⱥ��
    pick=rand;
%     while pick==0   
%         pick=rand;       
%     end
    for j=1:popsize   
        pick=pick-sumf(j);       
        if pick<0                  
            index=[index j];           
            break; 
        end
    end
end
%����Ⱥ
individuals.chrom=individuals.chrom(index,:);   %individuals.chromΪ��Ⱥ�и���
individuals.fitness=individuals.fitness(index);

ret=individuals;
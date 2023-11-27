clc
clear
% 指定参数文件的路径
pathname='E:\batch\vertical\';
load([pathname,'Abraham.mat']);
velocity_coeff=[10. 5. 1. 0.2 0.1];
%材料参数编号、密度比、粘度、初始速度
parameter_end=zeros(length(parameter(:,1))*length(velocity_coeff),4);
%密度比、粘度、初始速度、材料参数编号
parameter_end_extend=zeros(length(parameter(:,1)),length(velocity_coeff),4);
pathname='E:\batch\vertical\result\';
% 逐行读取参数并生成超算任务脚本
for j=1:length(parameter(:,1))
    for m=1:length(velocity_coeff)
        %总工况参数汇总：材料参数编号、密度比、粘度、初始速度
        parameter_end((j-1)*length(velocity_coeff)+m,1)=j;
        parameter_end((j-1)*length(velocity_coeff)+m,2)=parameter(j,1);
        parameter_end((j-1)*length(velocity_coeff)+m,3)=parameter(j,2);
        parameter_end((j-1)*length(velocity_coeff)+m,4)=velocity_coeff(m)*parameter(j,3); 
        parameter_end_extend(j,m,1)=parameter(j,1);
        parameter_end_extend(j,m,2)=parameter(j,2);
        parameter_end_extend(j,m,3)=velocity_coeff(m)*parameter(j,3);
        parameter_end_extend(j,m,4)=j;
        % 提取参数名称和参数值
        paramName = ['para_', num2str(j),'_v_', num2str(m)];
        % 创建文件夹，如果不存在的话
        folderName = [pathname, paramName];
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        % 提取参数名称, 构建超算任务脚本文件名
        scriptFilename = [folderName,'/job_','para_', num2str(j),'_v_', num2str(m), '.sh'];
        % 打开作业脚本文件以写入
        scriptFileID = fopen(scriptFilename, 'w');
        if scriptFileID == -1
            error('无法创建作业脚本文件 %s', scriptFilename);
        end
        % 写入超算任务脚本内容
        fprintf(scriptFileID, "#!/bin/bash\n");
        fprintf(scriptFileID, "#SBATCH -o %j\n");
        fprintf(scriptFileID, "#SBATCH -J Bucket\n");
        fprintf(scriptFileID, "#SBATCH -t 72:00:00\n");
        fprintf(scriptFileID, "#SBATCH -p xhacnormalb\n");
        fprintf(scriptFileID, "#SBATCH --ntasks-per-node=128\n");
        fprintf(scriptFileID, "#SBATCH -N 1\n");
        fprintf(scriptFileID, "module purge\n");
        fprintf(scriptFileID, "module load mpi/intelmpi/2021.3.0\n");
        fprintf(scriptFileID, "mpicc -Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 _sphere.c -o sphere.exe -lm\n");
        % 在脚本中添加参数值
        fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f %f > log 2>&1', parameter(j,1), parameter(j,2), velocity_coeff(m)*parameter(j,3));
        fprintf(scriptFileID, '\n');
        % 关闭作业脚本文件
        fclose(scriptFileID);
        fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
    end
end
figure;
plot(parameter_end_extend(:,:,4), parameter_end_extend(:,1,3),'k-*',parameter_end_extend(:,:,4), parameter_end_extend(:,2,3),'r-*',parameter_end_extend(:,:,4), parameter_end_extend(:,3,3),'b-*',parameter_end_extend(:,:,4), parameter_end_extend(:,4,3),'g-*',parameter_end_extend(:,:,4), parameter_end_extend(:,5,3),'y-*')
xlabel('case','FontSize',15,'FontName','Times New Rome');
ylabel('u_{ref}','FontSize',15,'FontName','Times New Rome');
legend('10u_{ref}','5u_{ref}','u_{ref}','0.2u_{ref}','0.1u_{ref}','FontSize',15,'FontName','Times New Rome');
set(gca,'FontName','Times New Rome','FontSize',15);

clc
clear
% 指定参数文件的路径
pathname='C:\Users\Administrator\Desktop\ZLH\bounce\paremeter\';
parameter_all=load([pathname,'parameter_all.mat']);

% 逐行读取参数并生成超算任务脚本
for j=1:length(parameter_all.parameter(:,1))
    for m=1:length(parameter_all.sita(:,1))
        for n=1:length(parameter_all.w(:,1))
                % 提取参数名称和参数值
                paramName = ['para_', num2str(j),'sita_', num2str(m),'w_', num2str(n)];
                % 创建文件夹，如果不存在的话
                folderName = [pathname, paramName];
                if ~exist(folderName, 'dir')
                    mkdir(folderName);
                end
            % 提取参数名称, 构建超算任务脚本文件名
            scriptFilename = [folderName,'/job_','para_', num2str(j),'sita_', num2str(m),'w_', num2str(n), '.sh'];
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
            for i = 1:length(parameter_all.parameter(:,1))
                %小球直径，域，起始球坐标，无量纲化雷诺数，无量纲化St,无限介质中下落速度，无量纲化动力粘度,角度，角速度
                fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f  %f %f  %f %f  %f %f  %f > log 2>&1', parameter_all.parameter(i,1), parameter_all.parameter(i,10), parameter_all.parameter(i,5), parameter_all.parameter(i,6), parameter_all.parameter(i,7), parameter_all.parameter(i,8), parameter_all.parameter(i,9), parameter_all.sita(i,1), parameter_all.w(i,1));
            end
            fprintf(scriptFileID, '\n');
            % 关闭作业脚本文件
            fclose(scriptFileID);
            fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
        end
    end
end



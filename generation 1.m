% 指定参数文件的路径
pathname='C:\Users\Administrator\Desktop\ZLH\bounce\paremeter\';
load([pathname,'parameter.mat']);

% 逐行读取参数并生成超算任务脚本
for j=1:length(parameter(:,1))

    % 提取参数名称, 构建超算任务脚本文件名
    scriptFilename = [pathname,'job_', num2str(j), '.sh'];

    % 打开作业脚本文件以写入
    scriptFileID = fopen(scriptFilename, 'w');

    if scriptFileID == -1
        error('无法创建作业脚本文件 %s', scriptFilename);
    end

    % 写入超算任务脚本内容
    fprintf(scriptFileID, "#!/bin/bash\n");
    fprintf(scriptFileID, "#SBATCH -o %j\n");
    fprintf(scriptFileID, "#SBATCH -J Bucket\n");
    fprintf(scriptFileID, "#SBATCH -t 24:00:00\n");
    fprintf(scriptFileID, "#SBATCH -p xhacnormalb\n");
    fprintf(scriptFileID, "#SBATCH --ntasks-per-node=128\n");
    fprintf(scriptFileID, "#SBATCH -N 1\n");
    fprintf(scriptFileID, "module purge\n");
    fprintf(scriptFileID, "module load mpi/intelmpi/2021.3.0\n");
    fprintf(scriptFileID, "mpicc -Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 _sphere.c -o sphere.exe -lm\n");
    % 添加更多的 Slurm 作业配置信息
% int maxlevel=8;
% int minlevel=5;
% float Re=600;
% float u_s=1.;
% 
% int main (int argc, char * argv[])
% {
%   if (argc > 1)
%     maxlevel = atoi (argv[1]);
%   if (argc > 2)
%     minlevel = atoi (argv[2]);
%   if (argc > 3)
%     Re = atof (argv[3]);
%   if (argc > 4)
%     u_s = atof (argv[4]);
%   
%   init_grid (1 << minlevel);
%   size (12.);
%   origin (-L0/2., -L0/2., -L0/2.);
%   mu = muv;
%   run();
% }                                                          max min Re us
    % 在脚本中运行任务，执行的命令是 mpirun -np 128 ./sphere.exe 12 9 600. 1 > log 2>&1
    

    % 在脚本中添加参数值
    for i = 1:length(parameter(:,1))
        %小球直径，域，起始球坐标，无量纲化雷诺数，无量纲化St,无限介质中下落速度，无量纲化动力粘度,角度，角速度
        fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f  %f %f  %f %f  %f > log 2>&1', parameter(i,1), parameter(i,10), parameter(i,5), parameter(i,6), parameter(i,7), parameter(i,8), parameter(i,9));
    end

    fprintf(scriptFileID, '\n');

    % 关闭作业脚本文件
    fclose(scriptFileID);

    fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
end


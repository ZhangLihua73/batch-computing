clc
clear
% 指定参数文件的路径
pathname='E:\batch\vertical\';
load([pathname,'Abraham.mat']);
% 源文件路径和名称
sourceFile = 'E:\batch\vertical\_sphere.c';
%起始速度控制
velocity_coeff=[0.25 0.5 1. 2 4 16];
%材料参数编号、密度比、粘度、初始速度、速度倍数、RE
parameter_end=zeros(length(parameter(:,1))*length(velocity_coeff),6);
%密度比、粘度、初始速度、材料参数编号、初始速度的几倍
parameter_end_extend=zeros(length(parameter(:,1)),length(velocity_coeff),5);
pathname='E:\batch\vertical\result\';
% 逐行读取参数并生成超算任务脚本
for j=1:length(parameter(:,1))
    for m=1:length(velocity_coeff)
        %总工况参数汇总：材料参数编号、密度比、粘度、初始速度
        parameter_end((j-1)*length(velocity_coeff)+m,1)=j;
        parameter_end((j-1)*length(velocity_coeff)+m,2)=parameter(j,1);
        parameter_end((j-1)*length(velocity_coeff)+m,3)=parameter(j,2);
        parameter_end((j-1)*length(velocity_coeff)+m,4)=velocity_coeff(m)*parameter(j,3);
        parameter_end((j-1)*length(velocity_coeff)+m,5)=velocity_coeff(m); 
        parameter_end_extend(j,m,1)=parameter(j,1);
        parameter_end_extend(j,m,2)=parameter(j,2);
        parameter_end_extend(j,m,3)=velocity_coeff(m)*parameter(j,3);
        parameter_end_extend(j,m,4)=j;
        parameter_end_extend(j,m,5)=velocity_coeff(m);
%         % 提取参数名称和参数值
%         paramName = ['para_', num2str(j),'_v_', num2str(m)];
%         % 创建文件夹，如果不存在的话
%         folderName = [pathname, paramName];
%         if ~exist(folderName, 'dir')
%             mkdir(folderName);
%         end
%         % 提取参数名称, 构建超算任务脚本文件名
%         scriptFilename = [folderName,'/job_','para_', num2str(j),'_v_', num2str(m), '.sh'];
%         % 打开作业脚本文件以写入
%         scriptFileID = fopen(scriptFilename, 'w');
%         if scriptFileID == -1
%             error('无法创建作业脚本文件 %s', scriptFilename);
%         end
%         % 写入超算任务脚本内容
%         fprintf(scriptFileID, "#!/bin/bash\n");
%         fprintf(scriptFileID, "#SBATCH -o %j\n");
%         fprintf(scriptFileID, "#SBATCH -J Bucket\n");
%         fprintf(scriptFileID, "#SBATCH -t 72:00:00\n");
%         fprintf(scriptFileID, "#SBATCH -p xhacnormalb\n");
%         fprintf(scriptFileID, "#SBATCH --ntasks-per-node=128\n");
%         fprintf(scriptFileID, "#SBATCH -N 1\n");
%         fprintf(scriptFileID, "module purge\n");
%         fprintf(scriptFileID, "module load mpi/intelmpi/2021.3.0\n");
%         fprintf(scriptFileID, "mpicc -Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 _sphere.c -o sphere.exe -lm\n");
%         % 在脚本中添加参数值
%         fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f %f > log 2>&1', parameter(j,1), parameter(j,2), velocity_coeff(m)*parameter(j,3));
%         fprintf(scriptFileID, '\n');
%         % 关闭作业脚本文件
%         fclose(scriptFileID);
%         fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
%         %%%%%%c文件的复制
%         % 构建目标文件路径和名称
%         targetFolder = [folderName];
%         % 复制源文件_sphere.c到目标文件
%         copyfile(sourceFile, targetFolder);
    end
end
for i=1:length(parameter_end(:,1))
    %材料参数编号、密度比、粘度、初始速度、速度倍数、RE
    parameter_end(i,6)=parameter_end(i,4)./parameter_end(i,3);
end
max_RE=1;
max=zeros(length(parameter_end(1,:)),1);
for i=1:length(parameter_end(:,1))
    %材料参数编号、密度比、粘度、初始速度、速度倍数、RE
    parameter_end(i,6)=parameter_end(i,4)./parameter_end(i,3);
    if(parameter_end(i,6)<=max)
        max_RE=parameter_end(i,6);
        for j=1:length(parameter_end(1,:))
            max(j,1)=parameter_end(i,j);
        end  
    end
end
figure;
% plot(parameter_end_extend(:,:,4), parameter_end_extend(:,1,3),'k-*',parameter_end_extend(:,:,4), parameter_end_extend(:,2,3),'r-*',parameter_end_extend(:,:,4), parameter_end_extend(:,3,3),'b-*',parameter_end_extend(:,:,4), parameter_end_extend(:,4,3),'g-*',parameter_end_extend(:,:,4), parameter_end_extend(:,5,3),'y-*')
axy1=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,1,3),'k-*')
hold on;
axy2=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,2,3),'r-*')
hold on;
axy3=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,3,3),'b-*')
hold on;
axy4=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,4,3),'g-*')
hold on;
axy5=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,5,3),'y-*')
hold on;
axy6=plot(parameter_end_extend(:,:,4), parameter_end_extend(:,6,3),'c-*')
hold on;
xlabel('case','FontSize',15,'FontName','Times New Rome');
ylabel('u_{ref}','FontSize',15,'FontName','Times New Rome');
legend([axy1(1),axy2(1),axy3(1),axy4(1),axy5(1),axy6(1)],'0.25u_{ref}','0.5u_{ref}','u_{ref}','2u_{ref}','4u_{ref}','16u_{ref}','FontSize',15,'FontName','Times New Rome');
set(gca,'FontName','Times New Rome','FontSize',15);

%%分为三组一组密度比不变、一组粘度不变、一组速度倍数不变
%%%%%%不变值——可变
rho_s=4.;
miu_s=0.01;
u_s_muti=2.;
%%%%%%%%%%%%
%总工况参数汇总：材料参数编号、密度比、粘度、初始速度、速度倍数——parameter_end(180,5);
condition1=parameter_end(:,2)==rho_s;
selectedValues=parameter_end(condition1,:);
rho1 = zeros(size(selectedValues));
% 将选定的值填充到短数组中
rho1(:,:) = selectedValues;
%%%%%%%%%%%%
% 判据
condition2=parameter_end(:,3)==miu_s;
% 根据判据选择一部分值
selectedValues=parameter_end(condition2,:);
% 创建短数组
miu2 = zeros(size(selectedValues));
% 将选定的值填充到短数组中
miu2(:,:) = selectedValues;
%%%%%%%%%%%%
condition3=parameter_end(:,5)==u_s_muti;
selectedValues=parameter_end(condition3,:);
u3 = zeros(size(selectedValues));
% 将选定的值填充到短数组中
u3(:,:) = selectedValues;
save ([pathname,'first1.mat'],'rho1','miu2','u3');
figure;
plot3(parameter_end(:,2),parameter_end(:,3),parameter_end(:,5),'k*',rho1(:,2),rho1(:,3),rho1(:,5),'r-*',miu2(:,2),miu2(:,3),miu2(:,5),'b-*',u3(:,2),u3(:,3),u3(:,5),'y-*')
xlabel('\rho_{p}','FontSize',15,'FontName','Times New Rome');
ylabel('\nu_{f}','FontSize',15,'FontName','Times New Rome');
zlabel('multiple of u_{ref}','FontSize',15,'FontName','Times New Rome');
legend('original','fixed /rho','fixed /nu','fixed u','FontSize',15,'FontName','Times New Rome');
set(gca,'FontName','Times New Rome','FontSize',15);
%%%%%%%%%%%%%%%首先批量计算工况
first=load([pathname,'first1.mat']);
pathname='E:\batch\vertical\result\first\1\';
% 逐行读取参数并生成超算任务脚本
for j=1:length(first.rho1(:,1))
        %总工况参数汇总：材料参数编号、密度比、粘度、初始速度
        % 提取参数名称和参数值
        paramName = ['para_', num2str(j)];
        % 创建文件夹，如果不存在的话
        folderName = [pathname, paramName];
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        % 提取参数名称, 构建超算任务脚本文件名
        scriptFilename = [folderName,'/job_','para_', num2str(j), '.sh'];
        % 打开作业脚本文件以写入
        scriptFileID = fopen(scriptFilename, 'w');
        if scriptFileID == -1
            error('无法创建作业脚本文件 %s', scriptFilename);
        end
        % 写入超算任务脚本内容
% #!/bin/bash
% #SBATCH -o %j
% #SBATCH -J Bucket
% #SBATCH -t 24:00:00
% #SBATCH -p xhacnormalb
% #SBATCH --ntasks-per-node=128
% #SBATCH -N 1
% 
% module purge
% module load mpi/intelmpi/2021.3.0 
% mpicc -Wall -std=c99 -O2 _sphere.c -o sphere.exe -lm
% mpirun -np 128 ./sphere.exe > log 2>&1
        fprintf(scriptFileID, "#!/bin/bash\n");
        fprintf(scriptFileID, "#SBATCH -o %%j\n");
        fprintf(scriptFileID, "#SBATCH -J Bucket\n");
        fprintf(scriptFileID, "#SBATCH -t 72:00:00\n");
        fprintf(scriptFileID, "#SBATCH -p xhacnormalb\n");
        fprintf(scriptFileID, "#SBATCH --ntasks-per-node=128\n");
        fprintf(scriptFileID, "#SBATCH -N 1\n");
        fprintf(scriptFileID, "module purge\n");
        fprintf(scriptFileID, "module load mpi/intelmpi/2021.3.0\n");
        fprintf(scriptFileID, "mpicc -Wall -std=c99 -D_XOPEN_SOURCE=700 -O2 _sphere.c -o sphere.exe -lm\n");
        % 在脚本中添加参数值——材料参数编号、密度比、粘度、初始速度、速度倍数
        fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f %f > log 2>&1', first.rho1(j,2), first.rho1(j,3), first.rho1(j,4));
        fprintf(scriptFileID, '\n');
        % 关闭作业脚本文件
        fclose(scriptFileID);
        fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
%         %%%%%%c文件的复制
%         % 构建目标文件路径和名称
%         targetFolder = [folderName];
%         % 复制源文件_sphere.c到目标文件
%         copyfile(sourceFile, targetFolder);
end
pathname='E:\batch\vertical\result\first\2\';
for j=1:length(first.miu2(:,1))
        %总工况参数汇总：材料参数编号、密度比、粘度、初始速度
        % 提取参数名称和参数值
        paramName = ['para_', num2str(j)];
        % 创建文件夹，如果不存在的话
        folderName = [pathname, paramName];
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        % 提取参数名称, 构建超算任务脚本文件名
        scriptFilename = [folderName,'/job_','para_', num2str(j), '.sh'];
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
        % 在脚本中添加参数值——材料参数编号、密度比、粘度、初始速度、速度倍数
        fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f %f > log 2>&1', first.miu2(j,2), first.miu2(j,3), first.miu2(j,4));
        fprintf(scriptFileID, '\n');
        % 关闭作业脚本文件
        fclose(scriptFileID);
        fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
%         %%%%%%c文件的复制
%         % 构建目标文件路径和名称
%         targetFolder = [folderName];
%         % 复制源文件_sphere.c到目标文件
%         copyfile(sourceFile, targetFolder);
end

pathname='E:\batch\vertical\result\first\3\';
for j=1:length(first.u3(:,1))
        %总工况参数汇总：材料参数编号、密度比、粘度、初始速度
        % 提取参数名称和参数值
        paramName = ['para_', num2str(j)];
        % 创建文件夹，如果不存在的话
        folderName = [pathname, paramName];
        if ~exist(folderName, 'dir')
            mkdir(folderName);
        end
        % 提取参数名称, 构建超算任务脚本文件名
        scriptFilename = [folderName,'/job_','para_', num2str(j), '.sh'];
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
        % 在脚本中添加参数值——材料参数编号、密度比、粘度、初始速度、速度倍数
        fprintf(scriptFileID, 'mpirun -np 128 ./sphere.exe  %f %f %f > log 2>&1', first.u3(j,2), first.u3(j,3), first.u3(j,4));
        fprintf(scriptFileID, '\n');
        % 关闭作业脚本文件
        fclose(scriptFileID);
        fprintf('已生成超算任务脚本文件：%s\n', scriptFilename);
%         %%%%%%c文件的复制
%         % 构建目标文件路径和名称
%         targetFolder = [folderName];
%         % 复制源文件_sphere.c到目标文件
%         copyfile(sourceFile, targetFolder);

end


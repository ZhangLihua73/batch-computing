   #!/bin/bash

   # 指定任务脚本的主目录
   mainDir='/path/to/mainDir'

   # 遍历主目录下的文件夹并提交任务
   for folder in "$mainDir"/*; do
       if [ -d "$folder" ]; then
           echo "进入文件夹：$folder"
           cd "$folder"
           sbatch job_para_*.sh
           cd ..
       fi
   done
 

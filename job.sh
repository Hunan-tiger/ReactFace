#!/bin/bash

#SBATCH -J react  ##任务名称(自定)
#SBATCH -o /home_data/home/v-lijm/projects/react/react%j.out   ##指定作业标准输出文件路径，job_%j.out（%j表示作业号）
#SBATCH -e /home_data/home/v-lijm/projects/react/react%j_err.out   ##指定作业报错信息输出文件路径

#SBATCH -p bme_gpu  ##指定作业分区，可以选bme_gpu bme_cpu bme_quick bme_cpu_small
#SBATCH -t 60:00:00   ##最长运行时间 (2-12:00:00)
#SBATCH -N 1    ##作业申请的节点数
#SBATCH --gres=gpu:1  ##申请gpu型号和数目，也可以--gres=gpu:NVIDIAA10080GBPCIe:1来指定GPU型号，申请CPU分区时要注释掉
#SBATCH --mem=128G  ##预留内存，最多128G
#SBATCH -n 8    ##CPU数量，最多为8,一个cpu有20个core


echo ${SLURM_JOB_NODELIST}    ##显示作业分区
echo start on $(date)    ##显示作业开始时间
## nvidia-smi   ##显示gpu信息   watch -n 1 nvidia-smi

source /home_data/home/v-lijm/anaconda3/etc/profile.d/conda.sh     ##改成自己的conda.sh路径
conda activate react

cd /home_data/home/v-lijm/projects/ReactFace    ##工作目录
## 离线任务
python train.py --batch-size 4 --gpu-ids 0 -lr 0.00001 --kl-p 0.00001 -e 50 -j 12 --outdir results/train_offline
## 有线任务
## python train.py --batch-size 4  --gpu-ids 0  -lr 0.00001  --kl-p 0.00001 -e 50  -j 12 --online  --window-size 16 --outdir results/train_online

## 离线任务评估
## python evaluate.py  --resume results/train_offline/best_checkpoint.pth  --gpu-ids 0  -b 4  -j 4  --outdir results/val_offline --split val
## python evaluate.py  --resume results/train_online/best_checkpoint.pth  --gpu-ids 0  -b 4  -j 4  --outdir results/val_offline --split val
## 有线任务评估
## python evaluate.py  --resume ./results/TransVAE/online/online_TransVAE.pth  --gpu-ids 0 -b 4  -j 4  --online --outdir results/val_online --split val
## python -m pytorch_fid  ./results/val_online/val/fid/real  ./results/val_online/val/fid/fake

echo end on $(date)



## 终端命令：
## sbatch xxx.sh 提交作业
## squeue -l 查看jodid等信息
## scancel <jodid> 取消作业
## scontrol show job <jodid>  查看正在运行作业的状态
## sinfo: 查看集群运算节点的状态


## 如何输出到终端：
## tail -f <path/job.out>  实时读取文件内容


## 调试
## salloc -p bme_gpu -N 1 -n 2 -t 1:00:00 --gres=gpu:1 --mem=128
## 记得用完要取消作业！！！
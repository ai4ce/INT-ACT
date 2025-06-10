#!/bin/bash

#SBATCH --job-name=pi0_baseline_bridge
#SBATCH --output=log/slurm/train/%x.out
#SBATCH --error=log/slurm/train/%x.err
#SBATCH --time=44:00:00
#SBATCH --nodes=1
#SBATCH --gres=gpu:4
#SBATCH --constraint="h100"
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=54
#SBATCH --mem=440G
#SBATCH --account=pr_109_tandon_advanced

# set all the paths to environment variables
source ./set_path.sh

# CPU check
TOTAL_CORES=$(nproc)
echo "TOTAL_CORES=$TOTAL_CORES"

echo "CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES"
NUM_GPU="$(nvidia-smi --list-gpus | wc -l)"
echo "NUM_GPU=$NUM_GPU"

# Compute OMP_NUM_THREADS (avoid division by zero)
OMP_THREADS=$((TOTAL_CORES / NUM_GPU))

# Ensure OMP_NUM_THREADS is at least 1
OMP_THREADS=$((OMP_THREADS > 0 ? OMP_THREADS : 1))
echo "OMP_NUM_THREADS=$OMP_THREADS"

export MASTER_ADDR=$(scontrol show hostname ${SLURM_NODELIST} | head -n 1)
find_free_port() {
    python -c "import socket; s = socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('', 0)); port = s.getsockname()[1]; s.close(); print(port)"
}
export MASTER_PORT=$(find_free_port)

# export NCCL_DEBUG=INFO
echo "Job restart count: $SLURM_RESTART_COUNT"

singularity exec --nv \
--overlay ${OVERLAY_EXT3}:ro \
/scratch/work/public/singularity/cuda12.1.1-cudnn8.9.0-devel-ubuntu22.04.2.sif \
/bin/bash -c "source ./set_path.sh; \
    export PATH='/ext3/uv:$PATH'; \
    source ./.venv/bin/activate; \
    export OMP_NUM_THREADS=$OMP_THREADS; \
    uv run torchrun \
    --nnodes=1 \
    --nproc_per_node=$NUM_GPU \
    --rdzv_id=$RANDOM \
    --rdzv_backend=c10d \
    --max-restarts=0 \
    --standalone \
    --rdzv_endpoint=$MASTER_ADDR:$MASTER_PORT \
    src/agent/run.py \
    --config_path config/train/pi0_baseline_bridge.yaml"


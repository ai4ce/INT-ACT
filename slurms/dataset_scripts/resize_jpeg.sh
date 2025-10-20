#!/bin/bash

#SBATCH --job-name=resize_jpeg
#SBATCH --output=log/slurm/dataset/%x.out
#SBATCH --error=log/slurm/dataset/%x.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=40
#SBATCH --mem=200G
#SBATCH --time=03:55:00
#SBATCH --account=pr_109_tandon_advanced

module purge
# increase limit on number of files opened in parallel to 20k --> conversion opens up to 1k temporary files in /tmp to store dataset during conversion
ulimit -n 20000

source ./set_path.sh

singularity exec \
/scratch/work/public/singularity/cuda11.8.86-cudnn8.7-devel-ubuntu22.04.2.sif \
/bin/bash -c "source ./set_path.sh; \
    export PATH='${HOME}/.local/bin/uv:$PATH'; \
    uv run scripts/dataset/modify_rlds_dataset.py \
        --dataset=bridge_dataset \
        --data_dir=/vast/work/public/ml-datasets/x-embodiment \
        --target_dir=$VLA_DATA_DIR/resize_224 \
        --mods=resize_and_jpeg_encode \
        --n_workers=40 \
        --max_episodes_in_memory=200"
#!/bin/bash

#SBATCH --job-name=convert_proprio
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=45
#SBATCH --mem=200G
#SBATCH --time=04:00:00
#SBATCH --output=log/slurm/dataset/%x.out
#SBATCH --error=log/slurm/dataset/%x.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=zf540@nyu.edu
#SBATCH --account=pr_109_tandon_advanced

module purge
# increase limit on number of files opened in parallel to 20k --> conversion opens up to 1k temporary files in /tmp to store dataset during conversion
ulimit -n 20000

source ./set_path.sh

# dataset: bridge_dataset, or fractal20220817_data
singularity exec \
--overlay ${OVERLAY_EXT3}:ro \
/scratch/work/public/singularity/cuda11.8.86-cudnn8.7-devel-ubuntu22.04.2.sif \
/bin/bash -c "export PATH='/ext3/uv:$PATH'; \
    source ./.venv/bin/activate; \
    uv run python scripts/dataset/modify_rlds_dataset.py \
        --dataset=fractal20220817_data \
        --data_dir=$VLA_DATA_DIR/resize_224 \
        --target_dir=$VLA_DATA_DIR/temp \
        --mods=convert_proprio_to_euler \
        --n_workers=40 \
        --max_episodes_in_memory=200"

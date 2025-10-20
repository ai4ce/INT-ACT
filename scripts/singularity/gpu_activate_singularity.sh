#!/bin/bash

singularity exec --nv \
	    --bind /usr/share/nvidia \
		--bind /usr/share/glvnd/egl_vendor.d/10_nvidia.json \
	    --bind /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json \
		--overlay pi_overlay.ext3:ro \
		--overlay /scratch/work/public/singularity/vulkan-1.4.309-cuda12.1.1-cudnn8.9.0-devel-ubuntu22.04.2.sqf:ro \
		/scratch/work/public/singularity/cuda12.1.1-cudnn8.9.0-devel-ubuntu22.04.2.sif /bin/bash

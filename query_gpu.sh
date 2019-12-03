echo "GPU: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader) (Power: $(nvidia-smi --query-gpu=power.draw --format=csv,noheader); Fan: $(nvidia-smi --query-gpu=fan.speed --format=csv,noheader))"
echo "Memory: $(nvidia-smi --query-gpu=memory.used --format=csv,noheader)/$(nvidia-smi --query-gpu=memory.total --format=csv,noheader) ($(nvidia-smi --query-gpu=utilization.memory --format=csv,noheader))"
echo "$(nvidia-smi --query-compute-apps=name,used_memory --format=csv,noheader)"

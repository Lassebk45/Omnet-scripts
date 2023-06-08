for ((i=1;i<=9;i++)); do
    sbatch -p dhabi -w dhabi0$i clear_scratch.sh
    sbatch -p naples -w naples0$i clear_scratch.sh
done
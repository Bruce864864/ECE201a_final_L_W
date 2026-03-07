#!/bin/bash
set -e

THERM_CONF="configs/thermal-configs/sip_hbm_dray_062325_1GPU_6HBM_3D_single_GPU.xml"
HEATSINK_CONF="configs/thermal-configs/heatsink_definitions.xml"
BONDING_CONF="configs/thermal-configs/bonding_definitions.xml"
HEATSINK="heatsink_water_cooled"
SYSTEM_TYPE="3D_1GPU"
HBM_STACK=8
DUMMY_SI=True

mkdir -p sweep_out

for TIM in 1 5 10 50; do
  OUT="sweep_out/tim_${TIM}"
  mkdir -p "$OUT"
  python3 therm.py \
    --therm_conf "$THERM_CONF" \
    --out_dir "$OUT" \
    --heatsink_conf "$HEATSINK_CONF" \
    --bonding_conf "$BONDING_CONF" \
    --heatsink "$HEATSINK" \
    --project_name "tim_${TIM}" \
    --is_repeat False \
    --hbm_stack_height "$HBM_STACK" \
    --system_type "$SYSTEM_TYPE" \
    --dummy_si "$DUMMY_SI" \
    --tim_cond_list "$TIM" \
    --infill_cond_list 1.6 \
    --underfill_cond_list 1.6

  python3 - <<PY
import pickle
r=pickle.load(open("$OUT/results.pkl","rb"))
gpu=[(k,v) for k,v in r.items() if k.endswith(".GPU")]
hbm=[(k,v) for k,v in r.items() if ".HBM" in k and k.endswith("HBM")]
def peak(lst): 
    return max(v[0] for k,v in lst) if lst else None
print("TIM=$TIM GPU_peak=", peak(gpu), "HBM_peak=", peak(hbm))
PY
done
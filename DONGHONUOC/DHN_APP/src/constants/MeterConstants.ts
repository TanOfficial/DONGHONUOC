import { DialogOption } from "../components/common/OptionDialog";

export enum MeterType {
    Co = 'Co',
    Dientu = 'Dientu'
}

export const MeterTypeOptions: DialogOption[] = [
    { label: 'Đồng hồ Cơ', icon: 'settings-outline', value: MeterType.Co, color: '#4CAF50' },
    { label: 'Điện tử (LCD)', icon: 'speedometer-outline', value: MeterType.Dientu, color: '#2196F3' }
];

export const MeterBrandOptions: Record<MeterType, DialogOption[]> = {
    [MeterType.Co]: [
        { label: 'ACTARIS', value: 'ACTARIS', icon: 'water-outline' },
        { label: 'AICHI-TOKEI', value: 'AICHI-TOKEI', icon: 'water-outline' },
        { label: 'ARAD', value: 'ARAD', icon: 'water-outline' },
        { label: 'BAYLAN', value: 'BAYLAN', icon: 'water-outline' },
        { label: 'B-METERS', value: 'B-METERS', icon: 'water-outline' },
        { label: 'DELTA', value: 'DELTA', icon: 'water-outline' },
        { label: 'DIEHL', value: 'DIEHL', icon: 'water-outline' },
        { label: 'ELSTER', value: 'ELSTER', icon: 'water-outline' },
        { label: 'ITRON', value: 'ITRON', icon: 'water-outline' },
        { label: 'KENT', value: 'KENT', icon: 'water-outline' },
        { label: 'KENT-S', value: 'KENT-S', icon: 'water-outline' },
        { label: 'SENSUS', value: 'SENSUS', icon: 'water-outline' },
        { label: 'WOLTEX', value: 'WOLTEX', icon: 'water-outline' },
        { label: 'ABB', value: 'ABB', icon: 'water-outline' },
    ],
    [MeterType.Dientu]: [
        { label: 'ABB', value: 'ABB', icon: 'flash-outline', color: '#E91E63' },
        { label: 'ACTARIS', value: 'ACTARIS', icon: 'flash-outline', color: '#E91E63' },
        { label: 'ARAD', value: 'ARAD', icon: 'flash-outline', color: '#E91E63' },
        { label: 'BAYLAN', value: 'BAYLAN', icon: 'flash-outline', color: '#E91E63' },
        { label: 'B-METERS', value: 'B-METERS', icon: 'flash-outline', color: '#E91E63' },
        { label: 'DIEHL', value: 'DIEHL', icon: 'flash-outline', color: '#E91E63' },
        { label: 'ELSTER', value: 'ELSTER', icon: 'flash-outline', color: '#E91E63' },
        { label: 'EMS', value: 'EMS', icon: 'flash-outline', color: '#E91E63' },
        { label: 'ITRON', value: 'ITRON', icon: 'flash-outline', color: '#E91E63' },
        { label: 'ITRON-NEVOS', value: 'ITRON-NEVOS', icon: 'flash-outline', color: '#E91E63' },
        { label: 'NEVOS-ITRON', value: 'NEVOS-ITRON', icon: 'flash-outline', color: '#E91E63' },
        { label: 'RYNAN', value: 'RYNAN', icon: 'flash-outline', color: '#E91E63' },
        { label: 'SENSUS', value: 'SENSUS', icon: 'flash-outline', color: '#E91E63' },
    ]
};

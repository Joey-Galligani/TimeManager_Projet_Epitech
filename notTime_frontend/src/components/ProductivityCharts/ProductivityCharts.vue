<script lang="ts">
import { defineComponent, type PropType, watch, onMounted, ref, onBeforeUnmount } from 'vue';
import * as echarts from 'echarts';

interface WorkingHour {
    start: number;
    end: number;
}

interface DayWorkingHours {
    date: string;
    totalWorkedHours: number;
    workingHours: WorkingHour[];
}

export default defineComponent({
    name: 'ProductivityCharts',
    props: {
        day: {
            type: Object as PropType<DayWorkingHours>,
            required: true,
        },
    },
    setup(props) {
        // References to the chart instances
        const pieChartInstance = ref<echarts.ECharts | null>(null);
        const heatmapChartInstance = ref<echarts.ECharts | null>(null);
        const barChartInstance = ref<echarts.ECharts | null>(null);

        // Function to draw the pie chart
        const drawPieChart = () => {
            if (pieChartInstance.value) {
                pieChartInstance.value.dispose(); // Dispose of existing instance
            }

            const element = document.getElementById('pieChart');
            if (element) {
                pieChartInstance.value = echarts.init(element);
                const totalWorkedHours = props.day.totalWorkedHours;
                const totalBreakTime =
                    props.day.workingHours.length > 1
                        ? props.day.workingHours.reduce((acc, curr, i, arr) => {
                            if (i === 0) return acc;
                            return acc + (curr.start - arr[i - 1].end);
                        }, 0)
                        : 0;
                const totalIdleTime = 24 - (totalWorkedHours + totalBreakTime);

                const option = {
                    title: {
                        text: 'Activity Distribution',
                        left: 'center',
                    },
                    tooltip: {
                        trigger: 'item',
                    },
                    series: [
                        {
                            name: 'Activity Distribution',
                            type: 'pie',
                            radius: '50%',
                            data: [
                                { value: totalWorkedHours, name: 'Working Hours' },
                                { value: totalBreakTime, name: 'Break Time' },
                                { value: totalIdleTime, name: 'Idle Time' },
                            ],
                            emphasis: {
                                itemStyle: {
                                    shadowBlur: 10,
                                    shadowOffsetX: 0,
                                    shadowColor: 'rgba(0, 0, 0, 0.5)',
                                },
                            },
                        },
                    ],
                };
                pieChartInstance.value.setOption(option);
            }
        };

        // Function to draw the heatmap
        const drawHeatmap = () => {
            if (heatmapChartInstance.value) {
                heatmapChartInstance.value.dispose(); // Dispose of existing instance
            }

            const element = document.getElementById('heatmapChart');
            if (element) {
                heatmapChartInstance.value = echarts.init(element);
                const hours = Array.from({ length: 24 }, (_, i) => i);
                const data = hours.map((hour) => {
                    const isWorking = props.day.workingHours.some(
                        (wh) => hour >= Math.floor(wh.start) && hour < Math.ceil(wh.end)
                    );
                    return isWorking ? 5 : 1; // Example data: if working, set value higher
                });

                const option = {
                    title: {
                        text: 'Hourly Activity Heatmap',
                        left: 'center',
                    },
                    tooltip: {
                        position: 'top',
                    },
                    xAxis: {
                        type: 'category',
                        data: hours.map((h) => `${h}:00`),
                        splitArea: {
                            show: true,
                        },
                    },
                    yAxis: {
                        type: 'category',
                        data: ['Activity'],
                        splitArea: {
                            show: true,
                        },
                    },
                    visualMap: {
                        min: 1,
                        max: 5,
                        calculable: true,
                        orient: 'horizontal',
                        left: 'center',
                        bottom: '15%',
                    },
                    series: [
                        {
                            name: 'Hourly Activity',
                            type: 'heatmap',
                            data: hours.map((hour) => [hour, 0, data[hour]]),
                            label: {
                                show: true,
                            },
                            emphasis: {
                                itemStyle: {
                                    shadowBlur: 10,
                                    shadowColor: 'rgba(0, 0, 0, 0.5)',
                                },
                            },
                        },
                    ],
                };
                heatmapChartInstance.value.setOption(option);
            }
        };

        // Function to draw the bar chart
        const drawBarChart = () => {
            if (barChartInstance.value) {
                barChartInstance.value.dispose(); // Dispose of existing instance
            }

            const element = document.getElementById('barChart');
            if (element) {
                barChartInstance.value = echarts.init(element);
                const hours = Array.from({ length: 24 }, (_, i) => i);
                const data = hours.map((hour) =>
                    props.day.workingHours.some(
                        (wh) => hour >= Math.floor(wh.start) && hour < Math.ceil(wh.end)
                    )
                        ? 1
                        : 0
                );

                const option = {
                    title: {
                        text: 'Hourly Productivity',
                        left: 'center',
                    },
                    xAxis: {
                        type: 'category',
                        data: hours.map((h) => `${h}:00`),
                    },
                    yAxis: {
                        type: 'value',
                    },
                    series: [
                        {
                            data: data,
                            type: 'bar',
                            itemStyle: {
                                color: '#6C63FF',
                            },
                        },
                    ],
                };
                barChartInstance.value.setOption(option);
            }
        };

        // Watch for changes in props.day to update charts
        watch(
            () => props.day,
            () => {
                drawPieChart();
                drawHeatmap();
                drawBarChart();
            },
            { immediate: true }
        );

        // Dispose charts when component is unmounted
        onBeforeUnmount(() => {
            if (pieChartInstance.value) pieChartInstance.value.dispose();
            if (heatmapChartInstance.value) heatmapChartInstance.value.dispose();
            if (barChartInstance.value) barChartInstance.value.dispose();
        });

        onMounted(() => {
            drawPieChart();
            drawHeatmap();
            drawBarChart();
        });

        return {};
    },
});
</script>

<template>
    <div class="flex flex-col gap-10">
        <!-- Pie Chart -->
        <div id="pieChart" class="w-full h-64"></div>

        <!-- Heatmap -->
        <div id="heatmapChart" class="w-full h-64"></div>

        <!-- Bar Chart -->
        <div id="barChart" class="w-full h-64"></div>
    </div>
</template>

<style scoped>
#pieChart,
#heatmapChart,
#barChart {
    background-color: white;
    border-radius: 1rem;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
}
</style>

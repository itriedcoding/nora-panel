// Nora Panel - Charts and Data Visualization JavaScript
class NoraCharts {
    constructor() {
        this.charts = new Map();
        this.colors = {
            primary: '#e94560',
            secondary: '#0f3460',
            success: '#4CAF50',
            warning: '#FF9800',
            error: '#F44336',
            info: '#2196F3',
            gradient: ['#e94560', '#0f3460', '#16213e', '#1a1a2e']
        };
        this.init();
    }

    init() {
        this.createChartStyles();
    }

    // Line Chart
    createLineChart(container, data, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 400;
        canvas.height = options.height || 200;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'line',
            canvas,
            ctx,
            data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        grid: { color: '#2a2a4a' },
                        ticks: { color: '#b0b0b0' }
                    },
                    y: {
                        grid: { color: '#2a2a4a' },
                        ticks: { color: '#b0b0b0' }
                    }
                },
                plugins: {
                    legend: {
                        labels: { color: '#ffffff' }
                    }
                },
                ...options
            }
        };

        this.renderLineChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderLineChart(chart) {
        const { ctx, data, options } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Set up chart area
        const padding = 40;
        const chartWidth = width - padding * 2;
        const chartHeight = height - padding * 2;
        
        // Find min/max values
        const allValues = data.datasets.flatMap(dataset => dataset.data);
        const minValue = Math.min(...allValues);
        const maxValue = Math.max(...allValues);
        const valueRange = maxValue - minValue;
        
        // Draw grid
        ctx.strokeStyle = '#2a2a4a';
        ctx.lineWidth = 1;
        
        // Vertical grid lines
        for (let i = 0; i <= 10; i++) {
            const x = padding + (chartWidth / 10) * i;
            ctx.beginPath();
            ctx.moveTo(x, padding);
            ctx.lineTo(x, height - padding);
            ctx.stroke();
        }
        
        // Horizontal grid lines
        for (let i = 0; i <= 5; i++) {
            const y = padding + (chartHeight / 5) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }
        
        // Draw data lines
        data.datasets.forEach((dataset, datasetIndex) => {
            ctx.strokeStyle = dataset.color || this.colors.gradient[datasetIndex % this.colors.gradient.length];
            ctx.lineWidth = 2;
            ctx.beginPath();
            
            dataset.data.forEach((value, index) => {
                const x = padding + (chartWidth / (dataset.data.length - 1)) * index;
                const y = height - padding - ((value - minValue) / valueRange) * chartHeight;
                
                if (index === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            });
            
            ctx.stroke();
            
            // Draw points
            ctx.fillStyle = dataset.color || this.colors.gradient[datasetIndex % this.colors.gradient.length];
            dataset.data.forEach((value, index) => {
                const x = padding + (chartWidth / (dataset.data.length - 1)) * index;
                const y = height - padding - ((value - minValue) / valueRange) * chartHeight;
                
                ctx.beginPath();
                ctx.arc(x, y, 4, 0, Math.PI * 2);
                ctx.fill();
            });
        });
        
        // Draw labels
        ctx.fillStyle = '#b0b0b0';
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'center';
        
        // X-axis labels
        data.labels.forEach((label, index) => {
            const x = padding + (chartWidth / (data.labels.length - 1)) * index;
            ctx.fillText(label, x, height - padding + 20);
        });
        
        // Y-axis labels
        for (let i = 0; i <= 5; i++) {
            const value = minValue + (valueRange / 5) * i;
            const y = height - padding - (chartHeight / 5) * i;
            ctx.textAlign = 'right';
            ctx.fillText(value.toFixed(1), padding - 10, y + 4);
        }
    }

    // Bar Chart
    createBarChart(container, data, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 400;
        canvas.height = options.height || 200;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'bar',
            canvas,
            ctx,
            data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        };

        this.renderBarChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderBarChart(chart) {
        const { ctx, data, options } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Set up chart area
        const padding = 40;
        const chartWidth = width - padding * 2;
        const chartHeight = height - padding * 2;
        
        // Find max value
        const maxValue = Math.max(...data.datasets.flatMap(dataset => dataset.data));
        
        // Calculate bar dimensions
        const barWidth = chartWidth / data.labels.length * 0.8;
        const barSpacing = chartWidth / data.labels.length * 0.2;
        
        // Draw grid
        ctx.strokeStyle = '#2a2a4a';
        ctx.lineWidth = 1;
        
        // Horizontal grid lines
        for (let i = 0; i <= 5; i++) {
            const y = padding + (chartHeight / 5) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }
        
        // Draw bars
        data.datasets.forEach((dataset, datasetIndex) => {
            const color = dataset.color || this.colors.gradient[datasetIndex % this.colors.gradient.length];
            
            dataset.data.forEach((value, index) => {
                const barHeight = (value / maxValue) * chartHeight;
                const x = padding + (chartWidth / data.labels.length) * index + barSpacing / 2;
                const y = height - padding - barHeight;
                
                // Draw bar
                ctx.fillStyle = color;
                ctx.fillRect(x, y, barWidth, barHeight);
                
                // Draw value on top
                ctx.fillStyle = '#ffffff';
                ctx.font = '12px Inter, sans-serif';
                ctx.textAlign = 'center';
                ctx.fillText(value.toString(), x + barWidth / 2, y - 5);
            });
        });
        
        // Draw labels
        ctx.fillStyle = '#b0b0b0';
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'center';
        
        // X-axis labels
        data.labels.forEach((label, index) => {
            const x = padding + (chartWidth / data.labels.length) * index + (chartWidth / data.labels.length) / 2;
            ctx.fillText(label, x, height - padding + 20);
        });
    }

    // Pie Chart
    createPieChart(container, data, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 300;
        canvas.height = options.height || 300;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'pie',
            canvas,
            ctx,
            data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        };

        this.renderPieChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderPieChart(chart) {
        const { ctx, data } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Calculate total
        const total = data.reduce((sum, item) => sum + item.value, 0);
        
        // Set up chart area
        const centerX = width / 2;
        const centerY = height / 2;
        const radius = Math.min(width, height) / 2 - 40;
        
        let currentAngle = -Math.PI / 2; // Start from top
        
        // Draw pie slices
        data.forEach((item, index) => {
            const sliceAngle = (item.value / total) * 2 * Math.PI;
            const color = item.color || this.colors.gradient[index % this.colors.gradient.length];
            
            // Draw slice
            ctx.beginPath();
            ctx.moveTo(centerX, centerY);
            ctx.arc(centerX, centerY, radius, currentAngle, currentAngle + sliceAngle);
            ctx.closePath();
            ctx.fillStyle = color;
            ctx.fill();
            
            // Draw label
            const labelAngle = currentAngle + sliceAngle / 2;
            const labelX = centerX + Math.cos(labelAngle) * (radius + 20);
            const labelY = centerY + Math.sin(labelAngle) * (radius + 20);
            
            ctx.fillStyle = '#ffffff';
            ctx.font = '12px Inter, sans-serif';
            ctx.textAlign = 'center';
            ctx.fillText(item.label, labelX, labelY);
            
            // Draw percentage
            const percentage = ((item.value / total) * 100).toFixed(1);
            ctx.fillText(`${percentage}%`, labelX, labelY + 15);
            
            currentAngle += sliceAngle;
        });
    }

    // Doughnut Chart
    createDoughnutChart(container, data, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 300;
        canvas.height = options.height || 300;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'doughnut',
            canvas,
            ctx,
            data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        };

        this.renderDoughnutChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderDoughnutChart(chart) {
        const { ctx, data } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Calculate total
        const total = data.reduce((sum, item) => sum + item.value, 0);
        
        // Set up chart area
        const centerX = width / 2;
        const centerY = height / 2;
        const outerRadius = Math.min(width, height) / 2 - 40;
        const innerRadius = outerRadius * 0.6;
        
        let currentAngle = -Math.PI / 2; // Start from top
        
        // Draw doughnut slices
        data.forEach((item, index) => {
            const sliceAngle = (item.value / total) * 2 * Math.PI;
            const color = item.color || this.colors.gradient[index % this.colors.gradient.length];
            
            // Draw outer arc
            ctx.beginPath();
            ctx.arc(centerX, centerY, outerRadius, currentAngle, currentAngle + sliceAngle);
            ctx.arc(centerX, centerY, innerRadius, currentAngle + sliceAngle, currentAngle, true);
            ctx.closePath();
            ctx.fillStyle = color;
            ctx.fill();
            
            // Draw label
            const labelAngle = currentAngle + sliceAngle / 2;
            const labelX = centerX + Math.cos(labelAngle) * (outerRadius + 20);
            const labelY = centerY + Math.sin(labelAngle) * (outerRadius + 20);
            
            ctx.fillStyle = '#ffffff';
            ctx.font = '12px Inter, sans-serif';
            ctx.textAlign = 'center';
            ctx.fillText(item.label, labelX, labelY);
            
            currentAngle += sliceAngle;
        });
        
        // Draw center text
        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 16px Inter, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('Total', centerX, centerY - 5);
        ctx.font = '14px Inter, sans-serif';
        ctx.fillText(total.toString(), centerX, centerY + 15);
    }

    // Area Chart
    createAreaChart(container, data, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 400;
        canvas.height = options.height || 200;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'area',
            canvas,
            ctx,
            data,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        };

        this.renderAreaChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderAreaChart(chart) {
        const { ctx, data, options } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Set up chart area
        const padding = 40;
        const chartWidth = width - padding * 2;
        const chartHeight = height - padding * 2;
        
        // Find min/max values
        const allValues = data.datasets.flatMap(dataset => dataset.data);
        const minValue = Math.min(...allValues);
        const maxValue = Math.max(...allValues);
        const valueRange = maxValue - minValue;
        
        // Draw grid
        ctx.strokeStyle = '#2a2a4a';
        ctx.lineWidth = 1;
        
        // Horizontal grid lines
        for (let i = 0; i <= 5; i++) {
            const y = padding + (chartHeight / 5) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }
        
        // Draw area
        data.datasets.forEach((dataset, datasetIndex) => {
            const color = dataset.color || this.colors.gradient[datasetIndex % this.colors.gradient.length];
            
            ctx.beginPath();
            ctx.moveTo(padding, height - padding);
            
            dataset.data.forEach((value, index) => {
                const x = padding + (chartWidth / (dataset.data.length - 1)) * index;
                const y = height - padding - ((value - minValue) / valueRange) * chartHeight;
                ctx.lineTo(x, y);
            });
            
            ctx.lineTo(width - padding, height - padding);
            ctx.closePath();
            
            // Create gradient
            const gradient = ctx.createLinearGradient(0, padding, 0, height - padding);
            gradient.addColorStop(0, color + '80');
            gradient.addColorStop(1, color + '20');
            
            ctx.fillStyle = gradient;
            ctx.fill();
            
            // Draw line
            ctx.strokeStyle = color;
            ctx.lineWidth = 2;
            ctx.beginPath();
            
            dataset.data.forEach((value, index) => {
                const x = padding + (chartWidth / (dataset.data.length - 1)) * index;
                const y = height - padding - ((value - minValue) / valueRange) * chartHeight;
                
                if (index === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            });
            
            ctx.stroke();
        });
        
        // Draw labels
        ctx.fillStyle = '#b0b0b0';
        ctx.font = '12px Inter, sans-serif';
        ctx.textAlign = 'center';
        
        // X-axis labels
        data.labels.forEach((label, index) => {
            const x = padding + (chartWidth / (data.labels.length - 1)) * index;
            ctx.fillText(label, x, height - padding + 20);
        });
    }

    // Gauge Chart
    createGaugeChart(container, value, maxValue, options = {}) {
        const canvas = document.createElement('canvas');
        canvas.width = options.width || 200;
        canvas.height = options.height || 200;
        container.appendChild(canvas);

        const ctx = canvas.getContext('2d');
        const chart = {
            type: 'gauge',
            canvas,
            ctx,
            value,
            maxValue,
            options: {
                responsive: true,
                maintainAspectRatio: false,
                ...options
            }
        };

        this.renderGaugeChart(chart);
        this.charts.set(container.id || Date.now(), chart);
        return chart;
    }

    renderGaugeChart(chart) {
        const { ctx, value, maxValue } = chart;
        const { width, height } = chart.canvas;
        
        ctx.clearRect(0, 0, width, height);
        
        // Set up chart area
        const centerX = width / 2;
        const centerY = height / 2;
        const radius = Math.min(width, height) / 2 - 20;
        
        // Draw background arc
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, Math.PI, 2 * Math.PI);
        ctx.strokeStyle = '#2a2a4a';
        ctx.lineWidth = 20;
        ctx.stroke();
        
        // Draw value arc
        const percentage = value / maxValue;
        const angle = Math.PI + (percentage * Math.PI);
        
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, Math.PI, angle);
        ctx.strokeStyle = this.getGaugeColor(percentage);
        ctx.lineWidth = 20;
        ctx.stroke();
        
        // Draw value text
        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 24px Inter, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText(value.toString(), centerX, centerY - 10);
        
        // Draw max value text
        ctx.font = '14px Inter, sans-serif';
        ctx.fillText(`/ ${maxValue}`, centerX, centerY + 15);
    }

    getGaugeColor(percentage) {
        if (percentage < 0.3) return this.colors.success;
        if (percentage < 0.7) return this.colors.warning;
        return this.colors.error;
    }

    // Update chart data
    updateChart(id, newData) {
        const chart = this.charts.get(id);
        if (chart) {
            chart.data = newData;
            this.renderChart(chart);
        }
    }

    renderChart(chart) {
        switch (chart.type) {
            case 'line':
                this.renderLineChart(chart);
                break;
            case 'bar':
                this.renderBarChart(chart);
                break;
            case 'pie':
                this.renderPieChart(chart);
                break;
            case 'doughnut':
                this.renderDoughnutChart(chart);
                break;
            case 'area':
                this.renderAreaChart(chart);
                break;
            case 'gauge':
                this.renderGaugeChart(chart);
                break;
        }
    }

    // Resize chart
    resizeChart(id, width, height) {
        const chart = this.charts.get(id);
        if (chart) {
            chart.canvas.width = width;
            chart.canvas.height = height;
            this.renderChart(chart);
        }
    }

    // Destroy chart
    destroyChart(id) {
        const chart = this.charts.get(id);
        if (chart) {
            chart.canvas.remove();
            this.charts.delete(id);
        }
    }

    // Create chart styles
    createChartStyles() {
        const style = document.createElement('style');
        style.textContent = `
            .chart-container {
                position: relative;
                width: 100%;
                height: 100%;
                background: #1e1e3f;
                border-radius: 8px;
                border: 1px solid #2a2a4a;
                padding: 20px;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            }

            .chart-title {
                font-size: 16px;
                font-weight: 600;
                color: #ffffff;
                margin-bottom: 16px;
                text-align: center;
            }

            .chart-legend {
                display: flex;
                flex-wrap: wrap;
                gap: 16px;
                margin-top: 16px;
                justify-content: center;
            }

            .chart-legend-item {
                display: flex;
                align-items: center;
                gap: 8px;
                font-size: 12px;
                color: #b0b0b0;
            }

            .chart-legend-color {
                width: 12px;
                height: 12px;
                border-radius: 2px;
            }

            .chart-tooltip {
                position: absolute;
                background: #1a1a2e;
                color: #ffffff;
                padding: 8px 12px;
                border-radius: 6px;
                font-size: 12px;
                pointer-events: none;
                z-index: 1000;
                box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
                border: 1px solid #2a2a4a;
            }

            .chart-loading {
                display: flex;
                align-items: center;
                justify-content: center;
                height: 200px;
                color: #b0b0b0;
                font-size: 14px;
            }

            .chart-error {
                display: flex;
                align-items: center;
                justify-content: center;
                height: 200px;
                color: #F44336;
                font-size: 14px;
                text-align: center;
            }

            .chart-controls {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 16px;
                flex-wrap: wrap;
            }

            .chart-control {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .chart-control label {
                font-size: 12px;
                color: #b0b0b0;
            }

            .chart-control select,
            .chart-control input {
                background: #2a2a4a;
                border: 1px solid #3a3a5a;
                border-radius: 4px;
                color: #ffffff;
                padding: 4px 8px;
                font-size: 12px;
            }

            .chart-export {
                display: flex;
                gap: 8px;
                margin-top: 16px;
                justify-content: center;
            }

            .chart-export button {
                background: #0f3460;
                border: none;
                color: #ffffff;
                padding: 6px 12px;
                border-radius: 4px;
                font-size: 12px;
                cursor: pointer;
                transition: background 0.15s ease;
            }

            .chart-export button:hover {
                background: #0a2a4a;
            }

            /* Responsive Design */
            @media (max-width: 768px) {
                .chart-container {
                    padding: 16px;
                }

                .chart-legend {
                    flex-direction: column;
                    align-items: center;
                }

                .chart-controls {
                    flex-direction: column;
                    align-items: stretch;
                }

                .chart-export {
                    flex-direction: column;
                }
            }
        `;
        document.head.appendChild(style);
    }

    // Export chart as image
    exportChart(id, format = 'png') {
        const chart = this.charts.get(id);
        if (chart) {
            const dataURL = chart.canvas.toDataURL(`image/${format}`);
            const link = document.createElement('a');
            link.download = `chart-${id}.${format}`;
            link.href = dataURL;
            link.click();
        }
    }

    // Get chart data as JSON
    getChartData(id) {
        const chart = this.charts.get(id);
        if (chart) {
            return {
                type: chart.type,
                data: chart.data,
                options: chart.options
            };
        }
        return null;
    }

    // Create chart from JSON data
    createChartFromData(container, chartData) {
        switch (chartData.type) {
            case 'line':
                return this.createLineChart(container, chartData.data, chartData.options);
            case 'bar':
                return this.createBarChart(container, chartData.data, chartData.options);
            case 'pie':
                return this.createPieChart(container, chartData.data, chartData.options);
            case 'doughnut':
                return this.createDoughnutChart(container, chartData.data, chartData.options);
            case 'area':
                return this.createAreaChart(container, chartData.data, chartData.options);
            case 'gauge':
                return this.createGaugeChart(container, chartData.value, chartData.maxValue, chartData.options);
            default:
                throw new Error(`Unknown chart type: ${chartData.type}`);
        }
    }
}

// Create global charts instance
const noraCharts = new NoraCharts();

// Export for use in other modules
window.noraCharts = noraCharts;
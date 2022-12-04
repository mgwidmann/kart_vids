export const HighlightHook = {
    mounted() {
        this.lastValue = this.el.innerHTML;
    },
    updated() {
        this.el.parentElement.parentElement.classList.remove("scaleInOut");
        const newValue = this.el.innerHTML;
        if (this.lastValue !== newValue) {
            this.lastValue = newValue;
            this.el.parentElement.parentElement.classList.add("scaleInOut");
        }
    },
}
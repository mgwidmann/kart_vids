export const ConfettiHook = {
    mounted() {
        this.confetti = new JSConfetti();
        this.confetti.addConfetti({ confettiNumber: 1000, });
        this.timer = setInterval(() => {
            this.confetti.addConfetti({ confettiNumber: 1000, });
        }, 3000);
    },
    destroyed() {
        this.confetti.clearCanvas();
        clearInterval(this.timer);
    },
}
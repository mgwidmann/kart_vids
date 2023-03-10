const NUMBER_OF_CONFETTI_EXPLOSIONS = 5;
export const ConfettiHook = {
    mounted() {
        this.confetti = new JSConfetti();
        this.confetti.addConfetti({ confettiNumber: 1000, });
        this.counter = 0;
        this.timer = setInterval(() => {
            if (this.counter < NUMBER_OF_CONFETTI_EXPLOSIONS - 1) {
                this.counter++;
                this.confetti.addConfetti({ confettiNumber: 1000, });
            } else {
                this.destroyed();
            }
        }, 3000);
    },
    updated() {
        const podium = document.getElementById("podium-box");
        if (!podium) {
            this.destroyed();
        }
    },
    destroyed() {
        this.confetti.clearCanvas();
        clearInterval(this.timer);
    },
}
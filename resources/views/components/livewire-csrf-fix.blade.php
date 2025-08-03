<script>
    document.addEventListener("DOMContentLoaded", function () {
        const token = document.head.querySelector('meta[name="csrf-token"]');
        if (token && window.Livewire) {
            Livewire.hook('message.sent', (message, component) => {
                message.headers['X-CSRF-TOKEN'] = token.content;
            });
        }
    });
</script>

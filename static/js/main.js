document.addEventListener('DOMContentLoaded', () => {
    // Add fade-in class to main content
    const main = document.querySelector('main');
    if (main) {
        main.classList.add('fade-in');
    }

    // Initialize tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Handle message auto-dismiss
    const messages = document.querySelectorAll('.alert:not(.alert-permanent)');
    messages.forEach((message) => {
        setTimeout(() => {
            message.classList.add('fade');
            setTimeout(() => {
                message.remove();
            }, 500);
        }, 5000);
    });
});
EOF < /dev/null
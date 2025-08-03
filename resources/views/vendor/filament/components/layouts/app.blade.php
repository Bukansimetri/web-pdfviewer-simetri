<x-filament::layouts.app>
    @push('head')
        <meta name="csrf-token" content="{{ csrf_token() }}">
    @endpush

    {{ $slot }}
</x-filament::layouts.app>

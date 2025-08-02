<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Document extends Model
{
    protected $fillable = ['title', 'description', 'file_path', 'slug'];

    protected static function boot()
    {
        parent::boot();

        static::creating(function ($doc) {
            $doc->slug = (string) Str::uuid(); // contoh: 6645ef78660c9
        });
    }

    public function getPublicLinkAttribute()
    {
        return url("/files/{$this->slug}.pdf");
    }
}

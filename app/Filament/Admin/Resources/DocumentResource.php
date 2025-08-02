<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\DocumentResource\Pages;
use App\Models\Document;
use Filament\Forms;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Columns\ViewColumn;
use Str;

class DocumentResource extends Resource
{
    protected static ?string $model = Document::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form->schema([
            TextInput::make('title')->required()->maxLength(255),
            Textarea::make('description')->maxLength(1000),
            Forms\Components\Hidden::make('slug')
                ->default(fn () => Str::uuid()->toString()),
            FileUpload::make('file_path')
                ->label('Upload Dokumen (PDF)')
                ->disk('public')
                ->directory('files')
                ->visibility('public')
                ->required()
                ->getUploadedFileNameForStorageUsing(function ($file, $record) {
                    $slug = $record->slug ?? Str::uuid()->toString();
                    $extension = $file->getClientOriginalExtension();

                    return $slug . '.' . $extension;
                }),
        ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table
            ->columns([
                TextColumn::make('title')->searchable()->sortable(),
                TextColumn::make('slug')->label('Public URL')->formatStateUsing(function ($state) {
                    return url("/files/{$state}.pdf");
                }),
                TextColumn::make('created_at')->dateTime()->label('Uploaded At'),
                ViewColumn::make('QR')
                    ->view('filament.tables.columns.qr-code')
                    ->state(function ($record) {
                        return url("storage/files/{$record->slug}.pdf");
                    }),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDocuments::route('/'),
            'create' => Pages\CreateDocument::route('/create'),
            'edit' => Pages\EditDocument::route('/{record}/edit'),
        ];
    }
}

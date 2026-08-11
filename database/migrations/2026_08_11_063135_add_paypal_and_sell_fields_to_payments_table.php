<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->unsignedBigInteger('sellID')->nullable()->after('appointmentID');

            $table->string('paypalOrderID')->nullable()->after('paymentMethod');
            $table->string('paypalCaptureID')->nullable()->after('paypalOrderID');
            $table->string('currency', 3)->nullable()->after('paypalCaptureID');
            $table->string('status')->nullable()->after('currency');

            $table->foreign('sellID')
                ->references('sellID')
                ->on('sells')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropForeign(['sellID']);

            $table->dropColumn([
                'sellID',
                'paypalOrderID',
                'paypalCaptureID',
                'currency',
                'status',
            ]);
        });
    }
};
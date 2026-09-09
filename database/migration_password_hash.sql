-- ============================================================
-- Migration : support du hachage des mots de passe (v4 securite)
-- A executer UNE fois sur la base GestionFichesTechniques.
-- Idempotent : peut etre execute plusieurs fois sans risque.
-- Les mots de passe en clair existants restent valables et sont
-- migres automatiquement vers SHA-256 + Salt au prochain login.
-- ============================================================

IF COL_LENGTH('dbo.Utilisateurs','PasswordHash') IS NULL
    EXEC('ALTER TABLE dbo.Utilisateurs ADD PasswordHash NVARCHAR(128) NULL');
GO

IF COL_LENGTH('dbo.Utilisateurs','Salt') IS NULL
    EXEC('ALTER TABLE dbo.Utilisateurs ADD Salt NVARCHAR(64) NULL');
GO

PRINT 'Migration OK : colonnes PasswordHash / Salt pretes.';
GO


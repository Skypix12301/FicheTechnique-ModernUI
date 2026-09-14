import React from 'react';
import { AppProvider, useApp } from './context/AppContext';
import { Sidebar } from './components/Sidebar';
import { Topbar } from './components/Topbar';
import { DashboardView } from './components/DashboardView';
import { ListeFichesView } from './components/ListeFichesView';
import { FicheEditorView } from './components/FicheEditorView';
import { ProjetsView } from './components/ProjetsView';
import { CatalogueView } from './components/CatalogueView';
import { ParametresView } from './components/ParametresView';
import { PrintModal } from './components/PrintModal';
import { LoginModal } from './components/LoginModal';
import { NotificationToast } from './components/NotificationToast';

const MainLayout: React.FC = () => {
  const { user, currentPage, selectedFicheId, printFiche, setPrintFiche } = useApp();

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-slate-50 dark:bg-slate-950">
      {/* Login Screen if user logged out */}
      {!user && <LoginModal />}

      {/* Persistent Sidebar Navigation */}
      <Sidebar />

      {/* Main Workspace Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        <Topbar />

        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          {currentPage === 'dashboard' && <DashboardView />}
          {currentPage === 'fiches' && <ListeFichesView />}
          {currentPage === 'nouvelle_fiche' && <FicheEditorView ficheId={null} />}
          {currentPage === 'fiche_detail' && <FicheEditorView ficheId={selectedFicheId} />}
          {currentPage === 'projets' && <ProjetsView />}
          {currentPage === 'catalogue' && <CatalogueView />}
          {currentPage === 'parametres' && <ParametresView />}
        </main>
      </div>

      {/* Official A4 Print Modal */}
      {printFiche && (
        <PrintModal fiche={printFiche} onClose={() => setPrintFiche(null)} />
      )}

      {/* Notification Toast */}
      <NotificationToast />
    </div>
  );
};

export function App() {
  return (
    <AppProvider>
      <MainLayout />
    </AppProvider>
  );
}

export default App;

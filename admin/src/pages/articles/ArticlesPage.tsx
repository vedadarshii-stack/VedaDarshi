import { ARTICLE_TABS, ARTICLES, LOCALES } from '../../data/mock';
import type { ArticleRow } from '../../data/mock';
import { useCollection } from '../../lib/useCollection';
import { DataSourceNotice } from '../../components/DataSourceNotice';
import './ArticlesPage.css';

const COLLECTION = 'articles';

/** Figma E4 · Articles CMS (node 34:2). */
export function ArticlesPage() {
  const { rows, state } = useCollection<ArticleRow>(COLLECTION);
  const articles = state.status === 'live' ? rows : ARTICLES;

  return (
    <>
      <header className="pageHead">
        <div className="pageHead__text">
          <h1 className="pageHead__title">Articles</h1>
          <p className="pageHead__subtitle">142 total · 8 drafts · 3 scheduled</p>
        </div>
        <button type="button" className="articles__new">＋ New Article</button>
      </header>

      <DataSourceNotice state={state} path={COLLECTION} />

      <div className="articles__tabs">
        {ARTICLE_TABS.map((tab, index) => (
          <button
            key={tab}
            type="button"
            className={index === 0 ? 'articles__tab articles__tab--active' : 'articles__tab'}
          >
            {tab}
          </button>
        ))}
      </div>

      <div className="card articles__list">
        {articles.map((article, index) => (
          <div key={article.title}>
            {index > 0 && <div className="table__divider" />}
            <div className="articles__row">
              <span
                className="articles__thumb"
                style={{
                  backgroundImage: `linear-gradient(142.52deg, ${article.thumbFrom} 0%, #0c1329 71.429%)`,
                }}
              >
                ✦
              </span>

              <span className="articles__text">
                <span className="articles__title">{article.title}</span>
                <span className="articles__meta">{article.meta}</span>
              </span>

              <span className="articles__locales">
                {LOCALES.map((locale) => (
                  <span
                    key={locale}
                    className={
                      article.translated.includes(locale)
                        ? 'articles__locale articles__locale--done'
                        : 'articles__locale'
                    }
                    title={
                      article.translated.includes(locale)
                        ? `${locale} translation ready`
                        : `${locale} translation missing`
                    }
                  >
                    {locale}
                  </span>
                ))}
              </span>

              <span className={`articles__status articles__status--${article.status.toLowerCase()}`}>
                {article.status}
              </span>

              <button type="button" className="articles__action" aria-label="Edit article">
                ✎
              </button>
              <button type="button" className="table__more" aria-label="More actions">
                ⋯
              </button>
            </div>
          </div>
        ))}
      </div>

      <p className="articles__warning">
        ⚠ 2 articles are missing regional translations. Untranslated content falls back to English
        in the app.
      </p>
    </>
  );
}

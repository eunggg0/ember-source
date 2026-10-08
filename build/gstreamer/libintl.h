/* 크로스오버 묶음의 libgintl(proxy-libintl) 은 g_libintl_* 이름으로 내보낸다. 그 이름으로 잇는다. */
#ifndef EMBER_PROXY_LIBINTL_H
#define EMBER_PROXY_LIBINTL_H
#ifdef __cplusplus
extern "C" {
#endif
char *g_libintl_gettext(const char *msgid);
char *g_libintl_dgettext(const char *domain, const char *msgid);
char *g_libintl_dcgettext(const char *domain, const char *msgid, int category);
char *g_libintl_ngettext(const char *msgid1, const char *msgid2, unsigned long n);
char *g_libintl_dngettext(const char *domain, const char *msgid1, const char *msgid2, unsigned long n);
char *g_libintl_dcngettext(const char *domain, const char *msgid1, const char *msgid2, unsigned long n, int category);
char *g_libintl_textdomain(const char *domain);
char *g_libintl_bindtextdomain(const char *domain, const char *dirname);
char *g_libintl_bind_textdomain_codeset(const char *domain, const char *codeset);
#ifdef __cplusplus
}
#endif
#define gettext g_libintl_gettext
#define dgettext g_libintl_dgettext
#define dcgettext g_libintl_dcgettext
#define ngettext g_libintl_ngettext
#define dngettext g_libintl_dngettext
#define dcngettext g_libintl_dcngettext
#define textdomain g_libintl_textdomain
#define bindtextdomain g_libintl_bindtextdomain
#define bind_textdomain_codeset g_libintl_bind_textdomain_codeset
#endif

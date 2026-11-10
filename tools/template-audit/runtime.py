"""Live browser coverage, including pages with no original admin/error template."""
import argparse, json, re
from urllib.parse import urlparse
from pathlib import Path
from playwright.sync_api import sync_playwright, expect
from audit import PAGES

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--admin-only',action='store_true');parser.add_argument('--url',default='https://localhost:7445');parser.add_argument('--output',required=True,type=Path);parser.add_argument('--chromium',default='/usr/bin/chromium');args=parser.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    results={'public':[],'admin':[],'special':[]};errors=[];missing=[];current=['']
    with sync_playwright() as p:
        browser=p.chromium.launch(executable_path=args.chromium,headless=True,args=['--no-sandbox'])
        context=browser.new_context(ignore_https_errors=True,viewport={'width':1440,'height':1000})
        context.route('**/*',lambda r:r.continue_() if r.request.url.startswith(args.url) else r.abort())
        page=context.new_page();page.on('pageerror',lambda e:errors.append({'path':current[0],'message':str(e),'stack':e.stack}))
        def response(r):
            if r.status>=400 and r.request.resource_type in ['script','stylesheet','font','image'] and r.url.startswith(args.url):missing.append({'path':current[0],'url':r.url,'status':r.status})
        page.on('response',response)
        for width,height in ([] if args.admin_only else [(1440,1000),(768,1024),(390,844)]):
            page.set_viewport_size({'width':width,'height':height})
            for name,(path,_) in PAGES.items():
                current[0]=path;assert page.goto(args.url+path).status==200
                page.locator('.prague-loader').wait_for(state='hidden');expect(page.locator('.main-menu > li')).to_have_count(5)
                assert page.locator('h1').count()==1,(path,'h1')
                ids=page.locator('[id]').evaluate_all('(nodes)=>nodes.map(n=>n.id)');assert len(ids)==len(set(ids)),(path,'duplicate ids')
                if width==390:
                    page.locator('.prague-nav-menu-icon a').click();expect(page.locator('.prague-header')).to_have_class(re.compile('open-menu'));page.locator('.prague-nav-menu-icon a').click();page.wait_for_timeout(350)
                if name=='project':
                    preview=page.locator('#mainPreview');assert urlparse(preview.get_attribute('src')).path.startswith('/media/')
                    assert page.locator('#slides .swiper-slide').count()>=10
                if name=='about':
                    page.locator('.counter-num').first.scroll_into_view_if_needed();expect(page.locator('.counter-num').first).to_have_attribute('data-counted','true');page.wait_for_timeout(1600)
                    assert page.locator('.counter-num').all_text_contents()==['40','10','10','20']
                if name=='contact':expect(page.locator('iframe')).to_have_attribute('src',re.compile(r'^https://www\.google\.com/maps'))
                overflow=page.evaluate('Math.max(0,document.documentElement.scrollWidth-window.innerWidth)')
                page.screenshot(path=str(args.output/f'live-{name}-{width}.png'),full_page=True)
                results['public'].append({'page':name,'width':width,'status':200,'duplicate_ids':False,'horizontal_overflow_px':overflow})
        current[0]='/admin/account/login';page.goto(args.url+current[0]);page.locator('#Email').fill('admin@example.test');page.locator('#Password').fill('Test-Only-Password!123');page.locator('button.btn-primary').click()
        host=json.loads((args.output/'host.json').read_text());pid=host['projectId']
        page.goto(args.url+'/admin/users');reset=page.locator('a[href*="resetpassword" i]').first.get_attribute('href')
        paths=['/admin/account/login','/admin/account/denied',reset,'/admin/content/edit','/admin','/admin/content','/admin/content/edit/'+str(pid),'/admin/media?contentId='+str(pid),'/admin/categories','/admin/categories/edit','/admin/settings','/admin/users','/admin/users/create']
        for width,height in [(1440,1000),(390,844)]:
            page.set_viewport_size({'width':width,'height':height})
            for index,path in enumerate(paths):
                current[0]=path;assert page.goto(args.url+path).status==(403 if path=='/admin/account/denied' else 200)
                assert page.locator('h1' if path=='/admin/account/login' else '.page-heading h1').count()==1,(path,'page heading')
                if '/content/edit' in path:expect(page.locator('.note-editable')).to_be_visible()
                overflow=page.evaluate('Math.max(0,document.documentElement.scrollWidth-window.innerWidth)')
                page.screenshot(path=str(args.output/f'admin-{index}-{width}.png'),full_page=True)
                results['admin'].append({'path':path,'width':width,'status':403 if path=='/admin/account/denied' else 200,'horizontal_overflow_px':overflow,'upstream_template':None})
        for path,status in [('/en/projects/audit-project-2',200),('/en/not-found',404),('/status/404',404),('/error',500)]:
            current[0]=path;assert page.goto(args.url+path).status==status;results['special'].append({'path':path,'status':status})
        results['page_errors']=errors;results['missing_assets']=missing
        browser.close()
    (args.output/('runtime-admin-results.json' if args.admin_only else 'runtime-results.json')).write_text(json.dumps(results,ensure_ascii=False,indent=2));print(json.dumps({'public_checks':len(results['public']),'admin_checks':len(results['admin']),'special_checks':len(results['special']),'page_errors':errors,'missing_assets':missing},ensure_ascii=False,indent=2))
    assert not errors and not missing,'Browser errors or missing assets found'
if __name__=='__main__':main()

@echo off

git fetch origin

git rev-list --count master > Temp\local_rep.tmp
git rev-list --count origin/master > Temp\remote_rep.tmp

REM git log --pretty=format:"%h - %an, %ar : %s" master..origin/master > Temp\commits_diff.tmp
git log --pretty=format:"%%ar by %%an -> %%s" master..origin/master > Temp\commits_diff.tmp
@echo off
cd /d "c:\projects\1 - project KalaKriti\kalakriti-3.0\lib"

:: Replace expired URLs with working Unsplash images
powershell -Command "(Get-Content 'screens\showroom_setup.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/BSML5JvnyV/bwaij4n0_expires_30_days\.png', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face' | Set-Content 'screens\showroom_setup.dart'"

powershell -Command "(Get-Content 'screens\upload_page.dart') -replace 'https://images\.unsplash\.com/photo-1506744038136-46273834b3fb\?auto=format&fit=crop&w=600', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\upload_page.dart'"

powershell -Command "(Get-Content 'screens\SearchPage.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/S5Gz3UHxLl/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\SearchPage.dart'"

powershell -Command "(Get-Content 'screens\digital_personal_dashboard.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/BSML5JvnyV/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\digital_personal_dashboard.dart'"

powershell -Command "(Get-Content 'screens\rasik_profile.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/uhjLWlJxTl/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face' | Set-Content 'screens\rasik_profile.dart'"

powershell -Command "(Get-Content 'screens\depth0_frame0_screen.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/BSML5JvnyV/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\depth0_frame0_screen.dart'"

powershell -Command "(Get-Content 'screens\landing_screen.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/xsjzl494EJ/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\landing_screen.dart'"

powershell -Command "(Get-Content 'screens\SocialLink.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/BSML5JvnyV/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face' | Set-Content 'screens\SocialLink.dart'"

powershell -Command "(Get-Content 'screens\story_generating_page.dart') -replace 'https://storage\.googleapis\.com/tagjs-prod\.appspot\.com/v1/9BCNdnhUVz/[^\"]*_expires_30_days\.png', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop' | Set-Content 'screens\story_generating_page.dart'"

echo All expired URLs have been replaced with working Unsplash images!
pause
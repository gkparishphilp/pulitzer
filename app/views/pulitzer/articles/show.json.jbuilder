json.title @media.title
json.subtitle @media.subtitle
json.category @media.category.to_s

json.description @media.sanitized_description
json.avatar @media.avatar

json.publish_at @media.publish_at

json.content @media.sanitized_content
# Private FET -  Private DNS Migration

## Steps

- [ ] 備份既有 Private DNS Zones 設定
- [ ] 新增既有 DNS Forwarding Ruleset
- [ ] 設定 DNS Forwarding Ruleset 連線至多個 Spoke VNET
- [ ] 搬遷既有 Private DNS Zone 至新的 Resource Group / Subscription
- [ ] 盤點清理 Private DNS Zones 設定
- [ ] 合併多個重複 Private DNS Zones 為單一一個
- [ ] 提供 Azure Policy 阻擋非允許 Resource Group 自建 Private DNS Zones
- [ ] (Optional) 地端 DNS Conditional Forwarder 改寫
- [ ] (Optional) 地端 DNS 清理設定


```bash
git clone https://pichuang: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@github.com/pichuang/private-fet-private-dns-migration
```